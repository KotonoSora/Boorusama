// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

//FIXME: don't reuse translation keys with favorites tags
class ImportTagsDialog extends ConsumerStatefulWidget {
  const ImportTagsDialog({
    super.key,
    this.padding,
    this.hint,
    required this.onImport,
  });

  final double? padding;
  final String? hint;
  final void Function(String tagString) onImport;

  @override
  ConsumerState<ImportTagsDialog> createState() => _ImportTagsDialogState();
}

class _ImportTagsDialogState extends ConsumerState<ImportTagsDialog> {
  final textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  'favorite_tags.import'.tr(),
                  style: context.textTheme.titleLarge,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: TextField(
                  controller: textController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintMaxLines: 6,
                    hintText:
                        '${widget.hint ?? 'favorite_tags.import_hint'.tr()}\n\n\n\n\n',
                    filled: true,
                    fillColor: context.theme.cardColor,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(
                        color: context.theme.colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder(
                valueListenable: textController,
                builder: (context, value, child) => ElevatedButton(
                  onPressed: value.text.isNotEmpty
                      ? () {
                          context.navigator.pop();
                          widget.onImport(value.text);
                        }
                      : null,
                  child: const Text('favorite_tags.import').tr(),
                ),
              ),
              SizedBox(height: widget.padding ?? 0),
              ElevatedButton(
                onPressed: () => context.navigator.pop(),
                child: const Text('favorite_tags.cancel').tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}