// ignore_for_file: avoid_print

import 'dart:io';
import 'package:codegen/codegen.dart';

import 'src/language_extractor.dart';
import 'src/language_generator.dart';

void main() async {
  final translationsDir = Directory('translations');
  if (!translationsDir.existsSync()) {
    print('translations directory not found');
    return;
  }

  await CodegenRunner().run(
    config: CodegenConfig(
      templateDirectory: 'tools/src',
      outputPath: '../../packages/i18n/lib/src/gen/languages.g.dart',
    ),
    generator: () async {
      final languages = await LanguageExtractor.extractLanguages(
        translationsDir,
      );
      return LanguageGenerator().generate(languages);
    },
  );
}
