import 'package:flutter/material.dart';

import '../data/mock_database.dart';
import '../models/province.dart';
import '../theme/app_theme.dart';

class ProvincePickerSheet extends StatelessWidget {
  final String currentProvinceId;

  const ProvincePickerSheet({super.key, required this.currentProvinceId});

  static Future<Province?> show(
      BuildContext context, String currentProvinceId) {
    return showModalBottomSheet<Province>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) =>
          ProvincePickerSheet(currentProvinceId: currentProvinceId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const Text(
              'เลือกจังหวัด',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'แสดงอีเว้นในจังหวัดที่เลือก',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            ...MockDatabase.provinces.map((p) {
              final isCurrent = p.id == currentProvinceId;
              return InkWell(
                onTap: () => Navigator.of(context).pop(p),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.accentYellow.withValues(alpha: 0.4)
                        : AppColors.chipBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place,
                          color: AppColors.accentPink, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            Text(p.nameEn,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      Text(
                        '${MockDatabase.eventsByProvince(p.id).length} events',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                      if (isCurrent)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check_circle,
                              color: AppColors.accentPink, size: 20),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
