import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/attendance_history_controller.dart';

class AttendanceHistoryScreen extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          if (controller.isLoading.value && controller.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GlassCard(
                  level: 2,
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar<Attendance>(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay.value,
                    selectedDayPredicate: (day) => controller.isSameDay(controller.selectedDay.value, day),
                    onDaySelected: controller.onDaySelected,
                    onPageChanged: controller.onPageChanged,
                    eventLoader: (day) {
                      final normalizedDay = DateTime.utc(day.year, day.month, day.day);
                      return controller.events[normalizedDay] ?? [];
                    },
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: isDark ? Colors.white : const Color(0xFF1D1B20)),
                      weekendTextStyle: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF424655)),
                      outsideTextStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF7A7582)),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF0053D3).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFF006B5C),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      titleTextStyle: TextStyle(color: isDark ? Colors.white : const Color(0xFF1D1B20), fontSize: 18, fontWeight: FontWeight.bold),
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.chevron_left, color: isDark ? Colors.white : const Color(0xFF1D1B20)),
                      rightChevronIcon: Icon(Icons.chevron_right, color: isDark ? Colors.white : const Color(0xFF1D1B20)),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF424655)),
                      weekendStyle: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF424655)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildEventList(isDark),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEventList(bool isDark) {
    final selectedDay = controller.selectedDay.value;
    if (selectedDay == null) {
      return Center(
        child: Text(
          'Select a day to view details',
          style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF7A7582)),
        ),
      );
    }

    final normalizedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
    final dayEvents = controller.events[normalizedDay] ?? [];

    if (dayEvents.isEmpty) {
      return Center(
        child: Text(
          'No attendance marked',
          style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF7A7582)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final record = dayEvents[index];
        final isVerified = record.geofenceVerified;
        return GlassCard(
          level: 2,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFF006B5C).withOpacity(0.1) : const Color(0xFFE8A800).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: PhosphorIcon(
                  isVerified ? PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone) : PhosphorIcons.warning(PhosphorIconsStyle.duotone),
                  color: isVerified ? const Color(0xFF006B5C) : const Color(0xFFE8A800),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marked at ${record.attendanceTime}',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1D1B20),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVerified ? 'Verified Location' : 'Outside Geofence',
                      style: TextStyle(
                        color: isVerified ? (isDark ? Colors.white70 : const Color(0xFF424655)) : const Color(0xFFE8A800),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).paddingOnly(bottom: 12);
      },
    );
  }
}
