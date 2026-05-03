import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/trip_plan.dart';
import '../services/location_service.dart';
import '../services/plan_generator.dart';
import '../theme/app_theme.dart';

class PlanResultScreen extends StatefulWidget {
  final TripPlan plan;
  final double? userLat;
  final double? userLng;

  const PlanResultScreen({
    super.key,
    required this.plan,
    this.userLat,
    this.userLng,
  });

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen>
    with SingleTickerProviderStateMixin {
  late TripPlan _plan;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
    _tab = TabController(length: _plan.days, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _reroll() {
    setState(() {
      _plan = PlanGenerator.generate(
        province: _plan.province,
        days: _plan.days,
        seed: DateTime.now().millisecondsSinceEpoch,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: _buildHeroCard(),
            ),
            _buildTabBar(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: List.generate(_plan.days, (i) {
                  return _buildDayTimeline(_plan.dayItems[i]);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _reroll,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shuffle, size: 16),
                  SizedBox(width: 4),
                  Text('สุ่มใหม่',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB199), Color(0xFFFFD26F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI SMART ITINERARY',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_plan.province.name} ${_plan.days} วัน',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Text(
            'หลงรักทันที',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('${_plan.days}', 'วัน'),
              const SizedBox(width: 20),
              _stat('${_plan.totalActivities}', 'กิจกรรม'),
              const SizedBox(width: 20),
              _stat('฿${_formatBudget(_plan.estimatedBudget)}', 'โดยประมาณ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900)),
        Text(label,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(999),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textPrimary,
        labelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        dividerColor: Colors.transparent,
        tabs: List.generate(
          _plan.days,
          (i) => Tab(text: 'วัน ${i + 1}', height: 36),
        ),
      ),
    );
  }

  Widget _buildDayTimeline(List<PlanItem> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('ยังไม่มีอีเว้นในจังหวัดนี้'),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: items.length,
      itemBuilder: (context, i) =>
          _timelineRow(items[i], isLast: i == items.length - 1),
    );
  }

  Widget _timelineRow(PlanItem item, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                item.slot.time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _slotColor(item.slot),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _slotColor(item.slot).withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.accentYellow,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(child: _slotCard(item)),
        ],
      ),
    );
  }

  double _distanceFor(EventItem e) {
    final lat = widget.userLat ?? _plan.province.latitude;
    final lng = widget.userLng ?? _plan.province.longitude;
    return LocationService.distanceKm(lat, lng, e.latitude, e.longitude);
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }

  String get _distanceOriginLabel =>
      (widget.userLat != null && widget.userLng != null)
          ? 'จากคุณ'
          : 'จากตัวเมือง';

  Widget _slotCard(PlanItem item) {
    final e = item.event;
    final dist = _distanceFor(e);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _slotColor(item.slot).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.slot.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _slotColor(item.slot),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            e.title,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on,
                  size: 12, color: AppColors.accentPink),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  e.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              Text(
                e.isFree ? 'ฟรี' : '฿${e.price}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: e.isFree
                      ? const Color(0xFF22B07D)
                      : AppColors.accentPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.directions_walk,
                  size: 12, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '$_distanceOriginLabel ${_formatDistance(dist)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_slotIcon(item.slot), size: 14),
                const SizedBox(width: 4),
                Text(
                  _slotAction(item.slot, e),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _slotColor(PlanSlot slot) {
    switch (slot) {
      case PlanSlot.spot:
        return AppColors.accentYellow;
      case PlanSlot.food:
        return const Color(0xFF7AC598);
      case PlanSlot.evening:
        return AppColors.accentPink;
    }
  }

  IconData _slotIcon(PlanSlot slot) {
    switch (slot) {
      case PlanSlot.spot:
        return Icons.map_outlined;
      case PlanSlot.food:
        return Icons.restaurant_menu;
      case PlanSlot.evening:
        return Icons.celebration_outlined;
    }
  }

  String _slotAction(PlanSlot slot, EventItem e) {
    switch (slot) {
      case PlanSlot.spot:
        return 'ดูแผนที่';
      case PlanSlot.food:
        return 'จองโต๊ะ';
      case PlanSlot.evening:
        return 'ดูรายละเอียด';
    }
  }

  String _formatBudget(int n) {
    if (n >= 1000) {
      final k = (n / 1000).toStringAsFixed(1);
      return '${k}K';
    }
    return n.toString();
  }
}
