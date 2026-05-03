import 'package:flutter/material.dart';

import '../data/mock_database.dart';
import '../models/event.dart';
import '../models/province.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_chip.dart';
import '../widgets/event_card.dart';
import '../widgets/province_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();

  Province? _selectedProvince;
  bool _detecting = true;
  String? _detectMessage;
  bool _userPickedManually = false;

  EventCategory? _categoryFilter;
  int _navIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    setState(() {
      _detecting = true;
      _detectMessage = null;
    });
    final result = await _locationService.detectCurrentProvince();
    if (!mounted) return;
    setState(() {
      _detecting = false;
      _detectMessage = result.errorMessage;
      if (!_userPickedManually) {
        _selectedProvince = result.province;
      }
    });
  }

  Future<void> _pickProvince() async {
    final province = await ProvincePickerSheet.show(
      context,
      _selectedProvince?.id ?? 'phuket',
    );
    if (province != null) {
      setState(() {
        _selectedProvince = province;
        _userPickedManually = true;
      });
    }
  }

  List<EventItem> get _visibleEvents {
    if (_selectedProvince == null) return [];
    var list = MockDatabase.eventsByProvince(_selectedProvince!.id);
    if (_categoryFilter != null) {
      list = list.where((e) => e.category == _categoryFilter).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              e.address.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final province = _selectedProvince;
    final events = _visibleEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _detectLocation,
                color: AppColors.accentPink,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  children: [
                    _buildHeader(province, events.length),
                    const SizedBox(height: 16),
                    _buildLocationBar(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildCategoryRow(),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'กำลังเกิดขึ้น',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'ดูทั้งหมด →',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentPink),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (events.isEmpty)
                      _buildEmptyState()
                    else
                      ...events.map((e) => EventCard(event: e)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            BottomNav(
              currentIndex: _navIndex,
              onTap: (i) {
                setState(() => _navIndex = i);
                if (i == 2) _pickProvince();
              },
              onCenterTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('สร้างอีเว้นใหม่ (mock)')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Province? province, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'สวัสดี ',
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const Text(
              'คุณนิว!',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentPink),
            ),
            const SizedBox(width: 4),
            const Text('✨', style: TextStyle(fontSize: 22)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          province == null
              ? 'กำลังหาตำแหน่งของคุณ...'
              : 'ที่${province.name}วันนี้ มี $count events น่าสนใจ',
          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildLocationBar() {
    return GestureDetector(
      onTap: _pickProvince,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentPink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.my_location,
                  size: 18, color: AppColors.accentPink),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ตำแหน่งปัจจุบัน',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textMuted)),
                  Text(
                    _detecting
                        ? 'กำลังตรวจจับ...'
                        : (_selectedProvince?.name ?? '—'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  if (_detectMessage != null && !_detecting)
                    Text(
                      _detectMessage!,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (_detecting)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentPink,
                ),
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('เปลี่ยน',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(width: 4),
                    Icon(Icons.expand_more, size: 16),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: const InputDecoration(
                hintText: 'หา event, ร้าน, สถาน',
                hintStyle: TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          CategoryChip(
            label: 'ทั้งหมด',
            selected: _categoryFilter == null,
            onTap: () => setState(() => _categoryFilter = null),
          ),
          const SizedBox(width: 8),
          ...EventCategory.values.map((c) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                label: c.label,
                selected: _categoryFilter == c,
                onTap: () => setState(() => _categoryFilter = c),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('🌧️', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text('ยังไม่มีอีเว้นในเงื่อนไขนี้',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('ลองเปลี่ยนหมวดหมู่ หรือจังหวัด',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
