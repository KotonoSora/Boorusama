// Package imports:
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

enum ExploreCategory {
  popular,
  mostViewed,
  hot,
}

extension DateTimeX on DateTime {
  DateTime subtractTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy.parseFromDateTime(this).subtract(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy.parseFromDateTime(this).subtract(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy.parseFromDateTime(this).subtract(months: 1).dateTime;
    }
  }

  DateTime addTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy.parseFromDateTime(this).add(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy.parseFromDateTime(this).add(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy.parseFromDateTime(this).add(months: 1).dateTime;
    }
  }
}
