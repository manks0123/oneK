import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_database.dart';
import '../models/event.dart';
import '../models/province.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/category_chip.dart';
import '../widgets/event_calendar.dart';
import '../widgets/event_card.dart';
import '../widgets/province_picker_sheet.dart';
import 'event_detail_screen.dart';
import 'login_screen.dart';
import 'plan_setup_screen.dart';

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
  DateTime? _selectedDay;
  bool _calendarExpanded = false;

  double? _userLat;
  double? _userLng;
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _detectLocation();
    _liveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
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
      _userLat = result.userLatitude;
      _userLng = result.userLongitude;
      if (!_userPickedManually) {
        _selectedProvince = result.province;
      }
    });
  }

  double? _distanceToEvent(EventItem e) {
    final lat = _userLat;
    final lng = _userLng;
    if (lat == null || lng == null) {
      if (_selectedProvince == null) return null;
      return LocationService.distanceKm(
        _selectedProvince!.latitude,
        _selectedProvince!.longitude,
        e.latitude,
        e.longitude,
      );
    }
    return LocationService.distanceKm(lat, lng, e.latitude, e.longitude);
  }

  void _openEventDetail(EventItem e) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          event: e,
          distanceKm: _distanceToEvent(e),
        ),
      ),
    );
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openPlanFlow() async {
    if (!AuthService.instance.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเข้าสู่ระบบก่อนใช้ระบบวางแพลน'),
        ),
      );
      await _openLogin();
      if (!AuthService.instance.isLoggedIn) return;
    }
    if (!mounted || _selectedProvince == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlanSetupScreen(
          initialProvince: _selectedProvince!,
          userLat: _userLat,
          userLng: _userLng,
        ),
      ),
    );
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
        _selectedDay = null;
      });
    }
  }

  List<EventItem> get _provinceEvents {
    if (_selectedProvince == null) return [];
    return MockDatabase.eventsByProvince(_selectedProvince!.id);
  }

  List<EventItem> get _visibleEvents {
    var list = _provinceEvents;
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
    if (_selectedDay != null) {
      final d = _selectedDay!;
      list = list
          .where((e) =>
              e.startAt.year == d.year &&
              e.startAt.month == d.month &&
              e.startAt.day == d.day)
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
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _buildLocationBar()),
                          const SizedBox(width: 8),
                          _buildCalendarPill(),
                        ],
                      ),
                    ),
                    _buildCalendarExpansion(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildAiPlanBanner(),
                    const SizedBox(height: 14),
                    _buildCategoryRow(),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedDay != null
                              ? 'อีเว้นวันที่ ${_selectedDay!.day}/${_selectedDay!.month}'
                              : 'กำลังเกิดขึ้น',
                          style: const TextStyle(
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
                      ...events.map((e) {
                        final now = DateTime.now();
                        return EventCard(
                          event: e,
                          isLive: e.isLiveAt(now),
                          distanceKm: _distanceToEvent(e),
                          onTap: () => _openEventDetail(e),
                        );
                      }),
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
              onCenterTap: _openPlanFlow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Province? province, int count) {
    return ValueListenableBuilder<AppUser?>(
      valueListenable: AuthService.instance.currentUser,
      builder: (context, user, _) {
        final displayName = user?.name ?? 'ผู้มาเยือน';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'สวัสดี ',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800),
                      ),
                      Flexible(
                        child: Text(
                          '$displayName!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentPink),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('✨', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                _buildAuthButton(user),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              province == null
                  ? 'กำลังหาตำแหน่งของคุณ...'
                  : 'ที่${province.name}วันนี้ มี $count events น่าสนใจ',
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAuthButton(AppUser? user) {
    if (user == null) {
      return GestureDetector(
        onTap: _openLogin,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentPink,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPink.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, size: 14, color: Colors.white),
              SizedBox(width: 4),
              Text('เข้าสู่ระบบ',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      onSelected: (v) {
        if (v == 'logout') {
          AuthService.instance.logout();
        } else if (v == 'plan') {
          _openPlanFlow();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'plan',
          child: Row(
            children: const [
              Icon(Icons.auto_awesome,
                  size: 16, color: AppColors.accentPink),
              SizedBox(width: 8),
              Text('สร้างแพลนทริป'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16),
              SizedBox(width: 8),
              Text('ออกจากระบบ'),
            ],
          ),
        ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.accentPink,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPink.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          user.initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
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

  Widget _buildAiPlanBanner() {
    return GestureDetector(
      onTap: _openPlanFlow,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFB199), Color(0xFFFFD26F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB199).withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI SMART ITINERARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'สร้างแพลนทริปอัตโนมัติด้วย AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white, size: 16),
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

  static const _thaiMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  Widget _buildCalendarPill() {
    final hasSelection = _selectedDay != null;
    final shown = _selectedDay ?? DateTime.now();
    final monthLabel = _thaiMonths[shown.month - 1];
    final beYear = shown.year + 543;

    return GestureDetector(
      onTap: () => setState(() => _calendarExpanded = !_calendarExpanded),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _calendarExpanded || hasSelection
              ? AppColors.accentYellow.withValues(alpha: 0.55)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$monthLabel $beYear',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  _calendarExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            Text(
              '${shown.day}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.05,
                color: AppColors.accentPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarExpansion() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _calendarExpanded
          ? Padding(
              padding: const EdgeInsets.only(top: 12),
              child: EventCalendar(
                events: _provinceEvents,
                selectedDay: _selectedDay,
                onDaySelected: (d) {
                  setState(() {
                    _selectedDay = d;
                    if (d != null) _calendarExpanded = false;
                  });
                },
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  static const _chipCategories = <EventCategory>[
    EventCategory.festival,
    EventCategory.food,
    EventCategory.workshop,
  ];

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
          ..._chipCategories.map((c) {
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
    final hasCategory = _categoryFilter != null;
    final hasSearch = _searchQuery.trim().isNotEmpty;
    final hasDay = _selectedDay != null;
    final hasFilter = hasCategory || hasSearch || hasDay;
    final provinceName = _selectedProvince?.name ?? 'จังหวัดที่เลือก';

    final String title;
    final String subtitle;
    if (hasCategory && !hasSearch && !hasDay) {
      title = 'ไม่พบ Event ในหมวดนี้';
      subtitle = 'ลองเลือกหมวดอื่น หรือกด "ทั้งหมด"';
    } else if (hasFilter) {
      title = 'ไม่พบ Event ตามเงื่อนไขนี้';
      subtitle = 'ลองล้างตัวกรอง หรือเลือกวันที่อื่น';
    } else {
      title = 'ตอนนี้ยังไม่มีอีเว้นใน$provinceName';
      subtitle = 'ลองเปลี่ยนจังหวัด หรือกลับมาดูใหม่อีกครั้ง';
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Text('🌧️', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              if (hasFilter)
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _categoryFilter = null;
                    _searchQuery = '';
                    _selectedDay = null;
                  }),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('ล้างตัวกรอง'),
                ),
              OutlinedButton.icon(
                onPressed: _pickProvince,
                icon: const Icon(Icons.place_outlined, size: 16),
                label: const Text('เปลี่ยนจังหวัด'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
