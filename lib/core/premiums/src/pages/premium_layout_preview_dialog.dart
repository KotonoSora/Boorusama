// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../themes/theme/types.dart';
import '../../../widgets/widgets.dart';
import '../../premiums.dart';
import '../providers/preview_providers.dart';
import '../routes/route_utils.dart';

class PremiumLayoutPreviewDialog extends ConsumerWidget {
  const PremiumLayoutPreviewDialog({
    required this.onStartPreview,
    required this.firstTime,
    super.key,
  });

  final void Function() onStartPreview;
  final bool firstTime;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      premiumLayoutPreviewProvider.select(
        (s) => s.status,
      ),
    );

    final previewMinutes = kPreviewDuration.inMinutes.toString();

    return BooruDialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.t.booru.appearance.image_viewer_layout.preview.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          const _PreviewText(),
          const SizedBox(height: 20),
          if (status == LayoutPreviewStatus.off) ...[
            FilledButton(
              style: FilledButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                ref.read(premiumLayoutPreviewProvider.notifier).enable();
                onStartPreview();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  context.t.booru.appearance.image_viewer_layout.preview
                      .start_limited_preview(
                        previewMinutes: previewMinutes,
                      ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ] else if (status == LayoutPreviewStatus.on && !firstTime) ...[
            FilledButton(
              style: FilledButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  context
                      .t
                      .booru
                      .appearance
                      .image_viewer_layout
                      .preview
                      .continue_preview_and_apply,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, false);
              goToPremiumPage(ref);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                context.t.premium.upgrade,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PreviewText extends ConsumerWidget {
  const _PreviewText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(
      premiumLayoutPreviewProvider.select(
        (s) => s.status,
      ),
    );

    final remaining = ref.watch(
      premiumLayoutPreviewProvider.select(
        (s) => s.remaining,
      ),
    );

    // Get preview duration in minutes for UI
    final previewMinutes = kPreviewDuration.inMinutes.toString();
    final colorScheme = Theme.of(context).colorScheme;

    if (status == LayoutPreviewStatus.on && remaining != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context
                .t
                .booru
                .appearance
                .image_viewer_layout
                .preview
                .currently_in_preview,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: colorScheme.hintColor,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  context
                      .t
                      .booru
                      .appearance
                      .image_viewer_layout
                      .preview
                      .time_left,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.hintColor.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatDurationForMedia(remaining),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Text(
        context.t.booru.appearance.image_viewer_layout.preview.description(
          previewMinutes: previewMinutes,
          brand: kPremiumBrandName,
        ),
        style: TextStyle(
          fontWeight: FontWeight.w400,
          color: colorScheme.hintColor,
        ),
      );
    }
  }
}
