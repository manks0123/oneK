import 'package:flutter/material.dart';

enum EventCategory {
  festival,
  food,
  workshop,
  music,
  market,
  art,
}

extension EventCategoryX on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.festival:
        return 'Festival';
      case EventCategory.food:
        return 'ของกิน';
      case EventCategory.workshop:
        return 'Workshop';
      case EventCategory.music:
        return 'ดนตรี';
      case EventCategory.market:
        return 'ตลาด';
      case EventCategory.art:
        return 'ศิลปะ';
    }
  }
}

class EventItem {
  final String id;
  final String title;
  final String provinceId;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime startAt;
  final String startTimeLabel;
  final EventCategory category;
  final bool isFree;
  final int? price;
  final List<Color> coverGradient;
  final String coverEmoji;

  const EventItem({
    required this.id,
    required this.title,
    required this.provinceId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.startAt,
    required this.startTimeLabel,
    required this.category,
    required this.isFree,
    required this.coverGradient,
    required this.coverEmoji,
    this.price,
  });
}
