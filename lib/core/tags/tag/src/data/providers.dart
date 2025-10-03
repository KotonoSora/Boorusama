// Dart imports:
import 'dart:ui';

// Package imports:
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/providers.dart';
import '../../../../theme/theme_configs.dart';
import '../types/tag_color_options.dart';
import '../types/tag_colors.dart';
import '../types/tag_extractor.dart';
import '../types/tag_repository.dart';
import 'tag_repository_impl.dart';

final emptyTagRepoProvider = Provider<TagRepository>(
  (ref) => EmptyTagRepository(),
);

final tagColorProvider = Provider.family<Color?, (BooruConfigAuth, String)>(
  (ref, params) {
    final (config, tag) = params;

    final colorBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType)
        ?.tagColorGenerator();

    // In case the color builder is null, which means there is no config selected
    if (colorBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);

    final colors =
        ref.watch(tagColorsProvider(config)) ??
        TagColors.fromBrightness(colorScheme.brightness);

    final color = colorBuilder.generateColor(
      TagColorOptions(
        tagType: tag,
        colors: colors,
      ),
    );

    final dynamicColors = ref.watch(enableDynamicColoringProvider);

    // If dynamic colors are disabled, return the color as is
    if (!dynamicColors) return color;

    return color?.harmonizeWith(colorScheme.primary);
  },
  dependencies: [
    enableDynamicColoringProvider,
    colorSchemeProvider,
    tagColorsProvider,
  ],
);

final tagColorsProvider = Provider.family<TagColors?, BooruConfigAuth>(
  (ref, config) {
    final colorsBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType)
        ?.tagColorGenerator();

    // In case the color builder is null, which means there is no config selected
    if (colorsBuilder == null) return null;

    final colorScheme = ref.watch(colorSchemeProvider);
    final customColors = ref.watch(customColorsProvider);

    final colors = customColors != null
        ? getTagColorsFromColorSettings(customColors)
        : colorsBuilder.generateColors(
            TagColorsOptions(
              brightness: colorScheme.brightness,
            ),
          );

    return colors;
  },
  dependencies: [
    colorSchemeProvider,
    customColorsProvider,
  ],
);

final tagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final repo = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    final tagRepo = repo?.tag(config);

    if (tagRepo != null) {
      return tagRepo;
    }

    return ref.watch(emptyTagRepoProvider);
  },
);

final tagExtractorProvider = Provider.family<TagExtractor?, BooruConfigAuth>(
  (ref, config) {
    final repository = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    if (repository == null) return null;

    return repository.tagExtractor(config);
  },
  name: 'tagExtractorProvider',
);
