import 'event.dart';
import 'province.dart';

enum PlanSlot { spot, food, evening }

extension PlanSlotX on PlanSlot {
  String get label {
    switch (this) {
      case PlanSlot.spot:
        return 'SPOT';
      case PlanSlot.food:
        return 'FOOD';
      case PlanSlot.evening:
        return 'EVENT';
    }
  }

  String get time {
    switch (this) {
      case PlanSlot.spot:
        return '09:00';
      case PlanSlot.food:
        return '12:30';
      case PlanSlot.evening:
        return '18:00';
    }
  }
}

class PlanItem {
  final PlanSlot slot;
  final EventItem event;

  const PlanItem({required this.slot, required this.event});
}

class TripPlan {
  final Province province;
  final int days;
  final List<List<PlanItem>> dayItems;
  final int estimatedBudget;

  const TripPlan({
    required this.province,
    required this.days,
    required this.dayItems,
    required this.estimatedBudget,
  });

  int get totalActivities =>
      dayItems.fold(0, (sum, list) => sum + list.length);
}
