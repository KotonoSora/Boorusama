// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';

Future<bool> launchExternalUrl(
  Uri url, {
  void Function()? onError,
  LaunchMode? mode,
}) async {
  if (!await launchUrl(
    url,
    mode: mode ?? LaunchMode.externalApplication,
  )) {
    onError?.call();

    return false;
  }

  return true;
}

ImageQuality getImageQuality({
  required ImageQuality presetImageQuality,
  GridSize? size,
}) {
  if (presetImageQuality != ImageQuality.automatic) return presetImageQuality;
  if (size == GridSize.small) return ImageQuality.low;

  return ImageQuality.high;
}

extension StringX on String {
  String removeUnderscoreWithSpace() => replaceAll('_', ' ');
}

String dateTimeToStringTimeAgo(
  DateTime time, {
  String locale = 'en',
}) {
  final now = DateTime.now();
  final diff = now.difference(time);
  final ago = now.subtract(diff);

  return timeago.format(ago, locale: locale);
}

void showSimpleSnackBar({
  required BuildContext context,
  required Widget content,
  Duration? duration,
  SnackBarBehavior? behavior,
  SnackBarAction? action,
}) {
  final width = MediaQuery.of(context).size.width;
  final snackbar = SnackBar(
    action: action,
    behavior: behavior ?? SnackBarBehavior.floating,
    duration: duration ?? const Duration(seconds: 6),
    elevation: 6,
    width: width > 400 ? 400 : width,
    content: content,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

Future<T?> showAdaptiveBottomSheet<T>(
  BuildContext context, {
  required Widget Function(BuildContext context) builder,
  bool expand = false,
}) {
  return Screen.of(context).size != ScreenSize.small
      ? showGeneralDialog<T>(
          context: context,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
        )
      : showBarModalBottomSheet<T>(
          context: context,
          barrierColor: Colors.black45,
          backgroundColor: Colors.transparent,
          builder: (context) => ConditionalParentWidget(
            condition: !expand,
            child: builder(context),
            conditionalBuilder: (child) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: child,
            ),
          ),
        );
}
