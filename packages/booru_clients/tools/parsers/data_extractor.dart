import 'package:yaml/yaml.dart';
import '../models/booru_config.dart';

class DataExtractor {
  static BooruConfig? extractGelbooruV2Config(YamlList yamlData) {
    for (final entry in yamlData) {
      if (entry is YamlMap && entry.containsKey('gelbooru_v2')) {
        return _parseGelbooruV2Config(entry['gelbooru_v2']);
      }
    }
    return null;
  }

  static Set<String> extractAllParams(YamlList yamlData) {
    final allParams = <String>{};

    for (final entry in yamlData) {
      if (entry is YamlMap) {
        for (final booruConfig in entry.values) {
          if (booruConfig is YamlMap) {
            _extractParamsFromConfig(booruConfig, allParams);
          }
        }
      }
    }

    return allParams;
  }

  static Set<String> extractParserNames(YamlList yamlData) {
    final parsers = <String>{};

    for (final entry in yamlData) {
      if (entry is YamlMap && entry.containsKey('gelbooru_v2')) {
        _extractParsersFromConfig(entry['gelbooru_v2'], parsers);
      }
    }

    return parsers;
  }

  static void _extractParsersFromConfig(YamlMap config, Set<String> parsers) {
    final features = config['features'] as YamlMap?;
    features?.values.forEach((feature) {
      if (feature is YamlMap && feature['parser'] != null) {
        parsers.add(feature['parser']);
      }
    });

    final sites = config['sites'] as YamlList?;
    sites?.forEach((site) {
      if (site is YamlMap) {
        final overrides = site['overrides'] as YamlMap?;
        overrides?.values.forEach((override) {
          if (override is YamlMap && override['parser'] != null) {
            parsers.add(override['parser']);
          }
        });
      }
    });
  }

  static BooruConfig _parseGelbooruV2Config(YamlMap configMap) {
    final globalParams = _parseGlobalParams(configMap['global-user-params']);
    final features = _parseFeatures(configMap['features']);
    final defaultAuth = _parseAuthConfig(configMap['auth']);
    final sites = _parseSites(configMap['sites'], defaultAuth);

    return BooruConfig(
      name: 'gelbooru_v2',
      globalUserParams: globalParams,
      features: features,
      sites: sites,
      defaultAuth: defaultAuth,
    );
  }

  static Map<String, String> _parseGlobalParams(dynamic params) {
    if (params == null) return {};

    return Map<String, String>.from(params as YamlMap);
  }

  static Map<String, FeatureConfig> _parseFeatures(dynamic features) {
    if (features == null) return {};

    final featuresMap = features as YamlMap;
    final result = <String, FeatureConfig>{};

    for (final entry in featuresMap.entries) {
      final featureId = entry.key as String;
      final config = entry.value as YamlMap;

      result[featureId] = FeatureConfig(
        type: config['type'] ?? 'api',
        endpoint: config['endpoint'] ?? '',
        parser: config['parser'],
        userParams: Map<String, String>.from(config['user-params'] ?? {}),
        capabilities: _parseTypedCapabilities(config['capabilities']),
      );
    }

    return result;
  }

  static List<CapabilityField>? _parseTypedCapabilities(dynamic capabilities) {
    if (capabilities == null) return null;
    if (capabilities is YamlMap && capabilities.isEmpty) return null;

    final capMap = capabilities as YamlMap;
    return capMap.entries.map((entry) {
      final key = entry.key as String;
      final value = entry.value;

      return CapabilityField(
        name: key,
        type: _dartTypeFromYamlValue(value),
        value: value,
      );
    }).toList();
  }

  static String _dartTypeFromYamlValue(dynamic value) {
    return switch (value.runtimeType) {
      const (bool) => 'bool',
      const (int) => 'int',
      const (double) => 'double',
      const (String) => 'String',
      const (YamlList) => 'List<dynamic>',
      const (YamlMap) => 'Map<String, dynamic>',
      _ => 'dynamic',
    };
  }

  static List<SiteConfig> _parseSites(dynamic sites, AuthConfig? defaultAuth) {
    if (sites == null) return [];

    final sitesList = sites as YamlList;
    final result = <SiteConfig>[];

    for (final site in sitesList) {
      if (site is YamlMap) {
        final url = site['url'] as String;
        final overrides = _parseOverrides(site['overrides']);
        final siteAuth = _parseAuthConfig(site['auth']);
        final mergedAuth = _mergeAuthConfig(defaultAuth, siteAuth, url);

        result.add(
          SiteConfig(
            url: url,
            overrides: overrides,
            auth: mergedAuth,
          ),
        );
      }
    }

    return result;
  }

  static AuthConfig? _parseAuthConfig(dynamic auth) {
    if (auth == null) return null;

    final authMap = auth as YamlMap;
    return AuthConfig(
      apiKeyUrl: authMap['api-key-url'] as String?,
      instructionsKey: authMap['instructions-key'] as String?,
      loginUrl: authMap['login-url'] as String?,
      required: authMap['required'] as bool?,
      cookie: authMap['cookie'] as String?,
    );
  }

  static AuthConfig? _mergeAuthConfig(
    AuthConfig? defaultAuth,
    AuthConfig? siteAuth,
    String siteUrl,
  ) {
    if (defaultAuth == null && siteAuth == null) return null;

    // If no default auth, just return site auth
    if (defaultAuth == null) return siteAuth;

    // If no site auth, merge default auth with site URL
    if (siteAuth == null) {
      return AuthConfig(
        apiKeyUrl: _resolveUrl(defaultAuth.apiKeyUrl, siteUrl),
        instructionsKey: defaultAuth.instructionsKey,
        loginUrl: _resolveUrl(defaultAuth.loginUrl, siteUrl),
        required: defaultAuth.required,
        cookie: defaultAuth.cookie,
      );
    }

    // Merge both, with site auth taking precedence
    return AuthConfig(
      apiKeyUrl:
          siteAuth.apiKeyUrl ?? _resolveUrl(defaultAuth.apiKeyUrl, siteUrl),
      instructionsKey: siteAuth.instructionsKey ?? defaultAuth.instructionsKey,
      loginUrl: siteAuth.loginUrl ?? _resolveUrl(defaultAuth.loginUrl, siteUrl),
      required: siteAuth.required ?? defaultAuth.required,
      cookie: siteAuth.cookie ?? defaultAuth.cookie,
    );
  }

  static String? _resolveUrl(String? urlOrPath, String siteUrl) {
    if (urlOrPath == null) return null;

    // If it's already a full URL, return as is
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return urlOrPath;
    }

    // If it's a relative path, join with site URL
    final baseUrl = Uri.parse(siteUrl);
    final resolvedUri = baseUrl.resolve(urlOrPath);
    return resolvedUri.toString();
  }

  static Map<String, OverrideConfig> _parseOverrides(dynamic overrides) {
    if (overrides == null) return {};

    final overridesMap = overrides as YamlMap;
    final result = <String, OverrideConfig>{};

    for (final entry in overridesMap.entries) {
      final featureId = entry.key as String;
      final config = entry.value as YamlMap;

      result[featureId] = OverrideConfig(
        type: config['type'],
        endpoint: config['endpoint'],
        parser: config['parser'],
        userParams: config['user-params'] != null
            ? Map<String, String>.from(config['user-params'])
            : null,
        capabilities: _parseTypedCapabilities(config['capabilities']),
      );
    }

    return result;
  }

  static void _extractParamsFromConfig(YamlMap config, Set<String> allParams) {
    // Extract global user params
    final globalParams = config['global-user-params'] as YamlMap?;
    if (globalParams != null) {
      allParams.addAll(globalParams.keys.cast<String>());
    }

    // Extract feature user params
    final features = config['features'] as YamlMap?;
    if (features != null) {
      for (final feature in features.values) {
        if (feature is YamlMap) {
          final userParams = feature['user-params'] as YamlMap?;
          if (userParams != null) {
            allParams.addAll(userParams.keys.cast<String>());
          }
        }
      }
    }

    // Extract site override params
    final sites = config['sites'] as YamlList?;
    if (sites != null) {
      for (final site in sites) {
        if (site is YamlMap) {
          final overrides = site['overrides'] as YamlMap?;
          if (overrides != null) {
            for (final override in overrides.values) {
              if (override is YamlMap) {
                final userParams = override['user-params'] as YamlMap?;
                if (userParams != null) {
                  allParams.addAll(userParams.keys.cast<String>());
                }
              }
            }
          }
        }
      }
    }
  }
}
