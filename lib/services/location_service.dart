import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../data/mock_database.dart';
import '../models/province.dart';

class LocationResult {
  final Province province;
  final double? distanceKm;
  final bool fromGps;
  final String? errorMessage;

  const LocationResult({
    required this.province,
    required this.fromGps,
    this.distanceKm,
    this.errorMessage,
  });
}

class LocationService {
  static const Province _fallback = Province(
    id: 'phuket',
    name: 'ภูเก็ต',
    nameEn: 'Phuket',
    latitude: 7.8804,
    longitude: 98.3923,
    radiusKm: 60,
  );

  Future<LocationResult> detectCurrentProvince() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          province: _fallback,
          fromGps: false,
          errorMessage: 'ระบบตำแหน่งปิดอยู่ ใช้ ภูเก็ต เป็นค่าเริ่มต้น',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return const LocationResult(
          province: _fallback,
          fromGps: false,
          errorMessage: 'ไม่ได้รับอนุญาตให้เข้าถึงตำแหน่ง',
        );
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return _matchNearestProvince(pos.latitude, pos.longitude);
    } catch (e) {
      return LocationResult(
        province: _fallback,
        fromGps: false,
        errorMessage: 'หาตำแหน่งไม่สำเร็จ: $e',
      );
    }
  }

  LocationResult _matchNearestProvince(double lat, double lng) {
    Province nearest = MockDatabase.provinces.first;
    double nearestDist = double.infinity;

    for (final p in MockDatabase.provinces) {
      final d = _haversineKm(lat, lng, p.latitude, p.longitude);
      if (d < nearestDist) {
        nearestDist = d;
        nearest = p;
      }
    }
    return LocationResult(
      province: nearest,
      distanceKm: nearestDist,
      fromGps: true,
    );
  }

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _deg2rad(double deg) => deg * math.pi / 180.0;
}
