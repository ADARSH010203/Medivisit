import 'dart:async';
import 'dart:ui';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/mark_attendance_controller.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MarkAttendanceController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF0053D3), Color(0xFF006B5C)],
          ).createShader(bounds),
          child: const Text(
            'MediVisit Pro',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: PhosphorIcon(
              PhosphorIcons.bell(PhosphorIconsStyle.duotone),
              color: isDark ? Colors.white70 : const Color(0xFF424655),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: MeshGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Date & Time Section
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEE, MMM d').format(_now),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF151C27),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      DateFormat('hh:mm').format(_now),
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0053D3),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('a').format(_now),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white60 : const Color(0xFF424655),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Main Fingerprint Button Action Area
                Obx(() {
                  final isMarked = controller.isLocationReady.value && !controller.isLoading.value;
                  
                  return Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glowing background aura (animate-pulse-slow)
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF0053D3).withOpacity(0.12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0053D3).withOpacity(0.2),
                                    blurRadius: 60,
                                    spreadRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Outer Ring Gradient Container
                          GestureDetector(
                            onTap: () {
                              if (controller.isLocationReady.value && !controller.isLoading.value) {
                                controller.markAttendance();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isMarked
                                      ? [const Color(0xFF007261), const Color(0xFF68FADD)]
                                      : [const Color(0xFF0053D3), const Color(0xFF68FADD)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isMarked ? const Color(0xFF007261) : const Color(0xFF0053D3)).withOpacity(0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    width: 180,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isMarked
                                          ? const LinearGradient(
                                              colors: [Color(0xFF006B5C), Color(0xFF44DDC1)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isMarked ? null : (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.85)),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: controller.isLoading.value
                                          ? const CircularProgressIndicator(color: Color(0xFF0053D3))
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                PhosphorIcon(
                                                  isMarked
                                                      ? PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone)
                                                      : PhosphorIcons.fingerprint(PhosphorIconsStyle.duotone),
                                                  size: 56,
                                                  color: isMarked ? Colors.white : const Color(0xFF0053D3),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  isMarked ? 'Marked In' : 'Mark In',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: isMarked ? Colors.white : (isDark ? Colors.white : const Color(0xFF151C27)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Obx(() => Text(
                            controller.isLocationReady.value ? 'Tap button to mark attendance' : 'Not marked yet today',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white60 : const Color(0xFF424655),
                            ),
                          )),
                    ],
                  );
                }),

                const SizedBox(height: 36),

                // Current Location Card
                GlassCard(
                  level: 2,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0053D3).withOpacity(0.12),
                        ),
                        child: Center(
                          child: PhosphorIcon(
                            PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                            color: const Color(0xFF0053D3),
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT LOCATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Obx(() => Text(
                                  controller.locationStatus.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : const Color(0xFF151C27),
                                  ),
                                )),
                            const SizedBox(height: 2),
                            const Text(
                              'Accuracy: ±5m',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // "This Week" Horizontal Calendar Strip
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'THIS WEEK',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF424655),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildWeekCalendarStrip(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekCalendarStrip(bool isDark) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final day = startOfWeek.add(Duration(days: index));
        final isToday = day.day == now.day && day.month == now.month;
        final isPast = day.isBefore(now) && !isToday;

        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 4 ? 0 : 8),
            child: GlassCard(
              level: isToday ? 3 : 1,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                children: [
                  Text(
                    DateFormat('EEE').format(day),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? const Color(0xFF0053D3) : (isDark ? Colors.white60 : const Color(0xFF424655)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF151C27),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPast
                          ? const Color(0xFF006B5C)
                          : (isToday ? const Color(0xFF0053D3) : Colors.grey.withOpacity(0.3)),
                      boxShadow: isPast
                          ? [
                              BoxShadow(
                                color: const Color(0xFF006B5C).withOpacity(0.6),
                                blurRadius: 8,
                                spreadRadius: 1,
                              )
                            ]
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
