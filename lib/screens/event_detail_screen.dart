import 'dart:async';

import 'package:flutter/material.dart';

import '../models/event.dart';
import '../theme/app_theme.dart';
import '../widgets/live_badge.dart';

class EventDetailScreen extends StatefulWidget {
  final EventItem event;
  final double? distanceKm;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.distanceKm,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Timer? _liveTimer;

  @override
  void initState() {
    super.initState();
    _liveTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final isLive = e.isLiveAt(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.background,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: e.coverGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 24,
                    bottom: 32,
                    child: Text(e.coverEmoji,
                        style: const TextStyle(fontSize: 80)),
                  ),
                  if (isLive)
                    const Positioned(
                      left: 20,
                      bottom: 20,
                      child: LiveBadge(fontSize: 13),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      e.category.label,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    e.title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 14),
                  _infoRow(Icons.event, _formatDate(e.startAt, e.endAt)),
                  const SizedBox(height: 8),
                  _infoRow(Icons.location_on, e.address),
                  if (widget.distanceKm != null) ...[
                    const SizedBox(height: 8),
                    _infoRow(Icons.directions_walk,
                        'ห่างจากคุณ ${_formatDistance(widget.distanceKm!)}'),
                  ],
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.local_offer,
                    e.isFree ? 'เข้าฟรี' : '฿${e.price}',
                    color: e.isFree
                        ? const Color(0xFF22B07D)
                        : AppColors.accentPink,
                    bold: true,
                  ),
                  const SizedBox(height: 22),
                  const Text('รายละเอียด',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    e.description,
                    style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('สนใจเข้าร่วมอีเว้นแล้ว!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'สนใจเข้าร่วม',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text,
      {Color? color, bool bold = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color ?? AppColors.accentPink),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color ?? AppColors.textPrimary,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime start, DateTime end) {
    String two(int n) => n.toString().padLeft(2, '0');
    final sameDay = start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;
    final startStr =
        '${start.day}/${start.month}/${start.year} ${two(start.hour)}:${two(start.minute)}';
    final endStr = sameDay
        ? '${two(end.hour)}:${two(end.minute)}'
        : '${end.day}/${end.month} ${two(end.hour)}:${two(end.minute)}';
    return '$startStr – $endStr';
  }

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }
}
