import 'dart:math';

import '../data/mock_database.dart';
import '../models/event.dart';
import '../models/province.dart';
import '../models/trip_plan.dart';

class PlanGenerator {
  static const int _foodEstimatePerDay = 300;

  static TripPlan generate({
    required Province province,
    required int days,
    int? seed,
  }) {
    final rng = Random(seed);
    final pool = MockDatabase.eventsByProvince(province.id);

    final foodPool = pool
        .where((e) => e.category == EventCategory.food)
        .toList();
    final spotPool = pool
        .where((e) =>
            e.category == EventCategory.market ||
            e.category == EventCategory.workshop ||
            e.category == EventCategory.art)
        .toList();
    final eveningPool = pool
        .where((e) =>
            e.category == EventCategory.festival ||
            e.category == EventCategory.music ||
            e.category == EventCategory.market)
        .toList();

    EventItem pick(List<EventItem> primary) {
      final src = primary.isNotEmpty ? primary : pool;
      return src[rng.nextInt(src.length)];
    }

    final dayItems = <List<PlanItem>>[];
    int totalCost = 0;

    for (int d = 0; d < days; d++) {
      if (pool.isEmpty) {
        dayItems.add(const []);
        continue;
      }

      final spot = pick(spotPool);
      final food = pick(foodPool);
      final eve = pick(eveningPool);

      final items = [
        PlanItem(slot: PlanSlot.spot, event: spot),
        PlanItem(slot: PlanSlot.food, event: food),
        PlanItem(slot: PlanSlot.evening, event: eve),
      ];
      dayItems.add(items);

      for (final p in items) {
        if (!p.event.isFree) totalCost += p.event.price ?? 0;
      }
      totalCost += _foodEstimatePerDay;
    }

    return TripPlan(
      province: province,
      days: days,
      dayItems: dayItems,
      estimatedBudget: totalCost,
    );
  }
}
