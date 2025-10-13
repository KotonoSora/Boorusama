// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../themes/theme/types.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.padding,
    this.backgroundColor,
    this.iconColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 40,
        minHeight: 40,
      ),
      child: Material(
        color:
            backgroundColor ??
            context.extendedColorScheme.surfaceContainerOverlay,
        shape: const CircleBorder(),
        child: InkWell(
          splashFactory: InkRipple.splashFactory,
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(8),
            child: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: Theme.of(context).iconTheme.copyWith(
                  color:
                      iconColor ??
                      context.extendedColorScheme.onSurfaceContainerOverlay,
                ),
              ),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
