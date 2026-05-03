import 'package:flutter/material.dart';

import '../data/mock_database.dart';
import '../models/province.dart';
import '../services/plan_generator.dart';
import '../theme/app_theme.dart';
import 'plan_result_screen.dart';

class PlanSetupScreen extends StatefulWidget {
  final Province initialProvince;
  final double? userLat;
  final double? userLng;

  const PlanSetupScreen({
    super.key,
    required this.initialProvince,
    this.userLat,
    this.userLng,
  });

  @override
  State<PlanSetupScreen> createState() => _PlanSetupScreenState();
}

class _PlanSetupScreenState extends State<PlanSetupScreen> {
  late Province _province;
  int _days = 3;

  @override
  void initState() {
    super.initState();
    _province = widget.initialProvince;
  }

  Future<void> _generate() async {
    final plan = PlanGenerator.generate(
      province: _province,
      days: _days,
    );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanResultScreen(
          plan: plan,
          userLat: widget.userLat,
          userLng: widget.userLng,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('สร้างแพลนทริป',
            style: TextStyle(fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB199), Color(0xFFFFD26F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI SMART ITINERARY',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w700,
                              )),
                          SizedBox(height: 2),
                          Text(
                            'จัดแพลนทริปอัตโนมัติจากอีเว้นในพื้นที่',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('จังหวัดปลายทาง',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MockDatabase.provinces.map((p) {
                  final selected = p.id == _province.id;
                  return GestureDetector(
                    onTap: () => setState(() => _province = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.accentPink
                            : Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentPink
                              : Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place,
                              size: 14,
                              color: selected
                                  ? Colors.white
                                  : AppColors.accentPink),
                          const SizedBox(width: 6),
                          Text(
                            p.name,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('จำนวนวัน',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (i) {
                  final n = i + 1;
                  final selected = n == _days;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i == 4 ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _days = n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accentYellow
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accentYellow
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$n วัน',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'สร้างแพลนด้วย AI',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
