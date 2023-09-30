// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/downloads/downloads.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/foundation/networking/networking.dart';
import 'package:boorusama/foundation/path.dart';

final downloadNotificationProvider = Provider<DownloadNotifications>((ref) {
  throw UnimplementedError();
});

final downloadUrlProvider =
    Provider.autoDispose.family<String, Post>((ref, post) {
  final settings = ref.watch(settingsProvider);

  if (post.isVideo) return post.sampleImageUrl;

  final url = switch (settings.downloadQuality) {
    DownloadQuality.original => post.originalImageUrl,
    DownloadQuality.sample => post.sampleImageUrl,
    DownloadQuality.preview => post.thumbnailImageUrl,
  };

  return sanitizedUrl(url);
});

String sanitizedUrl(String url) {
  final ext = extension(url);
  final indexOfQuestionMark = ext.indexOf('?');

  if (indexOfQuestionMark != -1) {
    final trimmedExt = ext.substring(0, indexOfQuestionMark);

    return url.replaceFirst(ext, trimmedExt);
  } else {
    return url;
  }
}

final downloadServiceProvider = Provider.family<DownloadService, BooruConfig>(
  (ref, config) {
    final dio = newDio(ref.watch(dioArgsProvider(config)));
    final notifications = ref.watch(downloadNotificationProvider);

    return DioDownloadService(
      dio,
      notifications,
      retryOn404: config.booruType.hasUnknownFullImageUrl,
    );
  },
  dependencies: [
    dioArgsProvider,
    downloadNotificationProvider,
    currentBooruConfigProvider,
  ],
);

class DownloadUrlBaseNameFileNameGenerator implements FileNameGenerator<Post> {
  @override
  String generateFor(Post item, String fileUrl) => basename(fileUrl);
}

class Md5OnlyFileNameGenerator implements FileNameGenerator<Post> {
  @override
  String generateFor(Post item, String fileUrl) =>
      '${item.md5}${extension(fileUrl)}';
}
