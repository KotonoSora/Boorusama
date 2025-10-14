// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/posts/details/types.dart';
import '../../../core/posts/details_parts/types.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import 'types.dart';

class SankakuUploaderFileDetailTile extends ConsumerWidget {
  const SankakuUploaderFileDetailTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<SankakuPost>(context);
    final uploaderName = post.uploaderName;

    return switch (uploaderName) {
      null => const SizedBox.shrink(),
      final name => UploaderFileDetailTile(
        uploaderName: name,
        onSearch: () => goToSearchPage(ref, tag: 'user:$name'),
      ),
    };
  }
}

final kSankakuPostDetailsUIBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<SankakuPost>(
          showSource: true,
        ),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<SankakuPost>(),
  },
  full: {
    DetailsPart.info: (context) =>
        const DefaultInheritedInformationSection<SankakuPost>(
          showSource: true,
        ),
    DetailsPart.toolbar: (context) =>
        const DefaultInheritedPostActionToolbar<SankakuPost>(),
    DetailsPart.tags: (context) =>
        const DefaultInheritedTagsTile<SankakuPost>(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<SankakuPost>(
          uploader: SankakuUploaderFileDetailTile(),
        ),
    DetailsPart.artistPosts: (context) =>
        const DefaultInheritedArtistPostsSection<SankakuPost>(),
  },
);
