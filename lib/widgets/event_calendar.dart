import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/event.dart';
import '../theme/app_theme.dart';

class EventCalendar extends StatefulWidget {
  final List<EventItem> events;
  final DateTime? selectedDay;
  final ValueChanged<DateTime?> onDaySelected;

  const EventCalendar({
    super.key,
    required this.events,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<EventCalendar> createState() => _EventCalendarState();
}

class _EventCalendarState extends State<EventCalendar> {
  late DateTime _focusedDay;
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay ?? DateTime.now();
  }

  @override
  void didUpdateWidget(covariant EventCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDay != null &&
        !isSameDay(widget.selectedDay, _focusedDay)) {
      _focusedDay = widget.selectedDay!;
    }
  }

  Map<DateTime, int> get _eventCountByDay {
    final map = <DateTime, int>{};
    for (final e in widget.events) {
      final key = DateTime(e.startAt.year, e.startAt.month, e.startAt.day);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  int _eventsOnDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return _eventCountByDay[key] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
            child: Row(
              children: [
                const Icon(Icons.calendar_month,
                    size: 18, color: AppColors.accentPink),
                const SizedBox(width: 6),
                const Text(
                  'ปฏิทินอีเว้น',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const Spacer(),
                if (widget.selectedDay != null)
                  GestureDetector(
                    onTap: () => widget.onDaySelected(null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.chipBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.close, size: 14),
                          SizedBox(width: 4),
                          Text('ล้างวันที่',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _format,
            availableCalendarFormats: const {
              CalendarFormat.month: 'เดือน',
              CalendarFormat.twoWeeks: '2 สัปดาห์',
              CalendarFormat.week: 'สัปดาห์',
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) =>
                widget.selectedDay != null &&
                isSameDay(widget.selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() => _focusedDay = focused);
              if (widget.selectedDay != null &&
                  isSameDay(widget.selectedDay, selected)) {
                widget.onDaySelected(null);
              } else {
                widget.onDaySelected(selected);
              }
            },
            onFormatChanged: (f) => setState(() => _format = f),
            onPageChanged: (focused) => _focusedDay = focused,
            eventLoader: (day) => List.generate(_eventsOnDay(day), (i) => i),
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              leftChevronIcon: const Icon(Icons.chevron_left,
                  color: AppColors.textPrimary, size: 20),
              rightChevronIcon: const Icon(Icons.chevron_right,
                  color: AppColors.textPrimary, size: 20),
              headerPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(fontSize: 11, color: AppColors.textMuted),
              weekendStyle: TextStyle(
                  fontSize: 11, color: AppColors.accentPink),
            ),
            calendarStyle: CalendarStyle(
              cellMargin: const EdgeInsets.all(4),
              todayDecoration: BoxDecoration(
                color: AppColors.accentYellow.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              todayTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.accentPink,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              defaultTextStyle: const TextStyle(fontSize: 12),
              weekendTextStyle: const TextStyle(
                  fontSize: 12, color: AppColors.accentPink),
              outsideTextStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.5)),
              markersAlignment: Alignment.bottomCenter,
              markersOffset: const PositionedOffset(bottom: 2),
              markersMaxCount: 1,
              markerDecoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              markerSize: 5,
            ),
          ),
        ],
      ),
    );
  }
}
