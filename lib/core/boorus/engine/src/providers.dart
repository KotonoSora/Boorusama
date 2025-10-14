// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../configs/config/types.dart';
import 'booru_builder.dart';
import 'booru_engine.dart';
import 'booru_repository.dart';

final booruEngineRegistryProvider = Provider<BooruEngineRegistry>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'booruEngineRegistryProvider',
);

final booruBuilderProvider = Provider.family<BooruBuilder?, BooruConfigAuth>(
  (ref, config) {
    final booruBuilder = ref
        .watch(booruEngineRegistryProvider)
        .getBuilder(config.booruType);

    return booruBuilder;
  },
  name: 'currentBooruBuilderProvider',
);

final booruRepoProvider = Provider.family<BooruRepository?, BooruConfigAuth>(
  (ref, config) {
    final booruRepo = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    return booruRepo;
  },
  name: 'currentBooruRepositoryProvider',
);
