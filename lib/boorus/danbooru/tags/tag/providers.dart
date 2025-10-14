// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/config/types.dart';
import '../../../../core/search/queries/types.dart';
import '../../../../core/tags/categories/types.dart';
import '../../../../core/tags/local/providers.dart';
import '../../../../core/tags/tag/providers.dart';
import '../../../../core/tags/tag/types.dart';
import '../../client_provider.dart';
import '../../posts/post/types.dart';
import 'src/query_composer.dart';

final danbooruTagRepoProvider = Provider.family<TagRepository, BooruConfigAuth>(
  (ref, config) {
    final client = ref.watch(danbooruClientProvider(config));

    return TagRepositoryBuilder(
      getTags: (tags, page, {cancelToken}) async {
        final data = await client.getTagsByName(
          page: page,
          hideEmpty: true,
          tags: tags,
          cancelToken: cancelToken,
        );

        return data
            .map(
              (d) => Tag(
                name: d.name ?? '',
                category: TagCategory.fromLegacyId(d.category ?? 0),
                postCount: d.postCount ?? 0,
              ),
            )
            .toList();
      },
    );
  },
);

final danbooruTagQueryComposerProvider =
    Provider.family<TagQueryComposer, BooruConfigSearch>(
      (ref, config) => DanbooruTagQueryComposer(config: config),
    );

final danbooruTagResolverProvider =
    Provider.family<TagResolver, BooruConfigAuth>((ref, config) {
      return TagResolver(
        tagCacheBuilder: () => ref.watch(tagCacheRepositoryProvider.future),
        siteHost: config.url,
        cachedTagMapper: const CachedTagMapper(),
        tagRepositoryBuilder: () => ref.read(danbooruTagRepoProvider(config)),
      );
    });

final danbooruTagExtractorProvider =
    Provider.family<TagExtractor, BooruConfigAuth>(
      (ref, config) {
        return TagExtractorBuilder(
          siteHost: config.url,
          tagCache: ref.watch(tagCacheRepositoryProvider.future),
          sorter: TagSorter.defaults(),
          fetcherBatch: (posts, options) async {
            final partial = <Tag>{};
            final raw = <Tag>{};

            for (final post in posts) {
              if (post case final DanbooruPost danbooruPost) {
                final tags = _extractTagsFromPost(danbooruPost);

                if (options.fetchTagCount) {
                  partial.addAll(tags);
                } else {
                  raw.addAll(tags);
                }
              } else {
                final tags = TagExtractor.extractTagsFromGenericPost(post);

                raw.addAll(tags);
              }
            }

            final tagResolver = ref.read(danbooruTagResolverProvider(config));
            final resolved = <Tag>{};
            if (partial.isNotEmpty) {
              resolved.addAll(
                await tagResolver.resolvePartialTags(
                  partial.toList(),
                  cancelToken: options.cancelToken,
                ),
              );
            }

            if (raw.isNotEmpty) {
              resolved.addAll(
                await tagResolver.resolveRawTags(
                  raw.map((e) => e.name).toSet(),
                  cancelToken: options.cancelToken,
                ),
              );
            }

            return resolved.toList();
          },
          fetcher: (post, options) {
            final tagResolver = ref.read(danbooruTagResolverProvider(config));

            if (post case final DanbooruPost danbooruPost) {
              final tags = _extractTagsFromPost(danbooruPost);

              if (!options.fetchTagCount) {
                return tags;
              }

              return tagResolver.resolvePartialTags(tags);
            } else {
              return tagResolver.resolveRawTags(post.tags);
            }
          },
        );
      },
    );

List<Tag> _extractTagsFromPost(DanbooruPost post) {
  final tags = <Tag>[];

  for (final t in post.artistTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.artist(),
      ),
    );
  }

  for (final t in post.copyrightTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.copyright(),
      ),
    );
  }

  for (final t in post.characterTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.character(),
      ),
    );
  }

  for (final t in post.metaTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.meta(),
      ),
    );
  }

  for (final t in post.generalTags) {
    tags.add(
      Tag.noCount(
        name: t,
        category: TagCategory.general(),
      ),
    );
  }

  return tags;
}
