import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/province.dart';

class MockDatabase {
  static const List<Province> provinces = [
    Province(
      id: 'phuket',
      name: 'ภูเก็ต',
      nameEn: 'Phuket',
      latitude: 7.8804,
      longitude: 98.3923,
      radiusKm: 60,
    ),
    Province(
      id: 'surat',
      name: 'สุราษฎร์ธานี',
      nameEn: 'Surat Thani',
      latitude: 9.1382,
      longitude: 99.3215,
      radiusKm: 80,
    ),
    Province(
      id: 'nakhon',
      name: 'นครศรีธรรมราช',
      nameEn: 'Nakhon Si Thammarat',
      latitude: 8.4304,
      longitude: 99.9633,
      radiusKm: 80,
    ),
  ];

  static final List<EventItem> events = [
    // ===== Phuket =====
    EventItem(
      id: 'pk-1',
      title: 'Phuket Old Town Festival',
      provinceId: 'phuket',
      address: 'ถ.ถลาง, ภูเก็ต',
      latitude: 7.8845,
      longitude: 98.3895,
      startAt: DateTime(2026, 5, 3, 18, 0),
      startTimeLabel: 'วันนี้ • เริ่ม 18:00',
      category: EventCategory.festival,
      isFree: true,
      coverEmoji: '🎪',
      coverGradient: const [Color(0xFFFFB199), Color(0xFFFF8FB2)],
    ),
    EventItem(
      id: 'pk-2',
      title: 'Patong Beach Music Night',
      provinceId: 'phuket',
      address: 'หาดป่าตอง, ภูเก็ต',
      latitude: 7.8965,
      longitude: 98.2964,
      startAt: DateTime(2026, 5, 4, 19, 30),
      startTimeLabel: 'พรุ่งนี้ • 19:30',
      category: EventCategory.music,
      isFree: false,
      price: 350,
      coverEmoji: '🎶',
      coverGradient: const [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
    ),
    EventItem(
      id: 'pk-3',
      title: 'ตลาดนัดอินดี้ ลาน Limelight',
      provinceId: 'phuket',
      address: 'Limelight Avenue, ภูเก็ต',
      latitude: 7.8856,
      longitude: 98.3935,
      startAt: DateTime(2026, 5, 5, 17, 0),
      startTimeLabel: '5 พ.ค. • 17:00',
      category: EventCategory.market,
      isFree: true,
      coverEmoji: '🛍️',
      coverGradient: const [Color(0xFFFFD26F), Color(0xFFFF9A8B)],
    ),
    EventItem(
      id: 'pk-4',
      title: 'Workshop ทำขนมพื้นเมืองอ่าโป้ง',
      provinceId: 'phuket',
      address: 'ย่านเมืองเก่า, ภูเก็ต',
      latitude: 7.8835,
      longitude: 98.3899,
      startAt: DateTime(2026, 5, 6, 10, 0),
      startTimeLabel: '6 พ.ค. • 10:00',
      category: EventCategory.workshop,
      isFree: false,
      price: 590,
      coverEmoji: '🍰',
      coverGradient: const [Color(0xFFFAD0C4), Color(0xFFFFD1FF)],
    ),

    // ===== Surat Thani =====
    EventItem(
      id: 'sr-1',
      title: 'งานเงาะโรงเรียนนาสาร',
      provinceId: 'surat',
      address: 'อ.บ้านนาสาร, สุราษฎร์ธานี',
      latitude: 8.7790,
      longitude: 99.3784,
      startAt: DateTime(2026, 5, 3, 9, 0),
      startTimeLabel: 'วันนี้ • 09:00',
      category: EventCategory.festival,
      isFree: true,
      coverEmoji: '🍒',
      coverGradient: const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
    ),
    EventItem(
      id: 'sr-2',
      title: 'Street Food Night ริมตาปี',
      provinceId: 'surat',
      address: 'ริมแม่น้ำตาปี, อ.เมือง',
      latitude: 9.1402,
      longitude: 99.3253,
      startAt: DateTime(2026, 5, 4, 17, 0),
      startTimeLabel: 'พรุ่งนี้ • 17:00',
      category: EventCategory.food,
      isFree: true,
      coverEmoji: '🍜',
      coverGradient: const [Color(0xFFFFE259), Color(0xFFFFA751)],
    ),
    EventItem(
      id: 'sr-3',
      title: 'ตลาดศิลป์ บนเกาะลำพู',
      provinceId: 'surat',
      address: 'เกาะลำพู, อ.เมือง',
      latitude: 9.1432,
      longitude: 99.3262,
      startAt: DateTime(2026, 5, 7, 16, 30),
      startTimeLabel: '7 พ.ค. • 16:30',
      category: EventCategory.art,
      isFree: false,
      price: 100,
      coverEmoji: '🎨',
      coverGradient: const [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
    ),

    // ===== Nakhon Si Thammarat =====
    EventItem(
      id: 'nk-1',
      title: 'งานเดือนสิบ ประจำปี',
      provinceId: 'nakhon',
      address: 'สวนสมเด็จฯ, อ.เมือง',
      latitude: 8.4321,
      longitude: 99.9636,
      startAt: DateTime(2026, 5, 3, 16, 0),
      startTimeLabel: 'วันนี้ • 16:00',
      category: EventCategory.festival,
      isFree: true,
      coverEmoji: '🏮',
      coverGradient: const [Color(0xFFF6D365), Color(0xFFFDA085)],
    ),
    EventItem(
      id: 'nk-2',
      title: 'หนังตะลุง รุ่นใหม่ Live',
      provinceId: 'nakhon',
      address: 'หอประชุม มอ.วิทยาเขตนคร',
      latitude: 8.6395,
      longitude: 99.9418,
      startAt: DateTime(2026, 5, 5, 19, 0),
      startTimeLabel: '5 พ.ค. • 19:00',
      category: EventCategory.art,
      isFree: false,
      price: 200,
      coverEmoji: '🎭',
      coverGradient: const [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    ),
    EventItem(
      id: 'nk-3',
      title: 'ของกินถนนท่าวัง',
      provinceId: 'nakhon',
      address: 'ถ.ท่าวัง, อ.เมือง',
      latitude: 8.4280,
      longitude: 99.9646,
      startAt: DateTime(2026, 5, 4, 18, 0),
      startTimeLabel: 'พรุ่งนี้ • 18:00',
      category: EventCategory.food,
      isFree: true,
      coverEmoji: '🍢',
      coverGradient: const [Color(0xFFFFAFBD), Color(0xFFFFC3A0)],
    ),
  ];

  static List<EventItem> eventsByProvince(String provinceId) {
    return events.where((e) => e.provinceId == provinceId).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
  }

  static Province provinceById(String id) {
    return provinces.firstWhere((p) => p.id == id);
  }
}
