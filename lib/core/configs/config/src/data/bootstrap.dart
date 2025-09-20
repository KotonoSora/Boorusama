// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../../foundation/loggers.dart';
import '../types/booru_config_repository.dart';
import 'booru_config_repository_hive.dart';

Future<BooruConfigRepository> createBooruConfigsRepo({
  required Logger logger,
  required Future<void> Function(int configId)? onCreateNew,
}) async {
  logger.debugBoot('Initialize booru config box');

  final isNewBox = !await Hive.boxExists('booru_configs');

  final booruConfigBox = await Hive.openBox<String>('booru_configs');

  if (isNewBox && onCreateNew != null) {
    logger.debugBoot('Add default booru config');

    final id = await booruConfigBox.add(
      HiveBooruConfigRepository.defaultValue(),
    );

    await onCreateNew(id);
  }

  logger
    ..debugBoot('Total booru config: ${booruConfigBox.length}')
    ..debugBoot('Initialize booru user repository');
  final booruUserRepo = HiveBooruConfigRepository(box: booruConfigBox);

  return booruUserRepo;
}
