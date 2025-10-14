// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../tags/_shared/tag_list_notifier.dart';
import '../../../../users/creator/providers.dart';
import '../../../../users/details/routes.dart';
import '../../../../users/details/types.dart';
import '../../../../users/user/providers.dart';
import '../../../post/types.dart';

class DanbooruFileDetails extends ConsumerWidget {
  const DanbooruFileDetails({
    required this.post,
    super.key,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagDetails = ref.watch(
      danbooruTagListProvider(ref.watchConfigAuth),
    )[post.id];
    final userColor = DanbooruUserColor.of(context);

    return FileDetailsSection(
      post: post,
      rating: tagDetails != null ? tagDetails.rating : post.rating,
      uploader: () {
        final uploader = ref.watch(danbooruCreatorProvider(post.uploaderId));

        return uploader != null
            ? Row(
                children: [
                  Flexible(
                    child: Material(
                      color: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: InkWell(
                        customBorder: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        onTap: () => goToUserDetailsPage(
                          ref,
                          details: UserDetails.fromCreator(uploader),
                        ),
                        child: Text(
                          uploader.name.replaceAll('_', ' '),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: userColor.fromLevel(uploader.level),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : null;
      }(),
      customDetails: () {
        final approver = ref.watch(danbooruCreatorProvider(post.approverId));

        return approver != null
            ? {
                context.t.post.detail.approver: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => goToUserDetailsPage(
                      ref,
                      details: UserDetails.fromCreator(approver),
                    ),
                    child: Text(
                      approver.name.replaceAll('_', ' '),
                      maxLines: 1,
                      style: TextStyle(
                        color: userColor.fromLevel(approver.level),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              }
            : null;
      }(),
    );
  }
}
