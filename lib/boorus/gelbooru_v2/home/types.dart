// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/home/types.dart';
import '../favorites/widgets.dart';

final kGelbooruV2AltHomeView = {
  ...kDefaultAltHomeView,
  const CustomHomeViewKey('favorites'): CustomHomeDataBuilder(
    displayName: (context) => context.t.profile.favorites,
    builder: (context, _) => const GelbooruV2FavoritesPage(),
  ),
};
