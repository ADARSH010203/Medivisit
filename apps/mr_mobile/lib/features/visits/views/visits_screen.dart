import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'package:mr_mobile/l10n/generated/app_localizations.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../l10n/l10n.dart';
import '../controllers/visits_controller.dart';
import '../../../app/routes.dart';


class VisitsScreen extends StatefulWidget {
  const VisitsScreen({super.key});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  final VisitsController _controller = Get.put(VisitsController());

  @override
  Widget build(BuildContext context) {
    final tr = L10n.tr(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr.doctorVisits),
        centerTitle: true,
      ),
      body: MeshGradientBackground(
        child: Column(
          children: [
            const _DiscoverBanner(),
            _buildDaySelector(),
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value && _controller.currentVisits.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (_controller.currentVisits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        PhosphorIcon(PhosphorIcons.calendarX(PhosphorIconsStyle.duotone), size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('No visits scheduled', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _controller.currentVisits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final visit = _controller.currentVisits[index];
                    return _buildVisitCard(visit, tr);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PillBottomNav(
        currentIndex: 1, // Visits tab
        onTap: (index) {
          if (index == 0) Get.toNamed(AppRoutes.dashboard);
          if (index == 2) Get.toNamed(AppRoutes.catalog);
          if (index == 3) Get.toNamed(AppRoutes.profile);
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 14,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final date = DateTime.now().subtract(Duration(days: 7 - index));
            return Obx(() {
              final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                  DateFormat('yyyy-MM-dd').format(_controller.selectedDate.value);
              return GestureDetector(
                onTap: () => _controller.selectDate(date),
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0053D3).withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date).toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildVisitCard(Visit visit, AppLocalizations tr) {
    String statusText;
    switch (visit.status) {
      case VisitStatus.visited:
        statusText = tr.visited;
        break;
      case VisitStatus.planned:
      default:
        statusText = tr.pending;
    }

    final isHighPriority = visit.notes?.toLowerCase().contains('priority') ?? false;

    return InkWell(
      onTap: () {},
      child: Stack(
        children: [
          GlassCard(
            level: 2,
            padding: EdgeInsets.zero,
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left timeline accent bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: visit.status == VisitStatus.visited
                            ? [const Color(0xFF006B5C), const Color(0xFF44DDC1)]
                            : [const Color(0xFF0053D3), const Color(0xFF44DDC1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: PhosphorIcon(
                              PhosphorIcons.user(PhosphorIconsStyle.duotone),
                              color: AppColors.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${visit.doctorId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Cardiologist • Apollo Hospital',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusPill(
                                  text: statusText,
                                  type: visit.status == VisitStatus.visited
                                      ? StatusPillType.success
                                      : StatusPillType.warning,
                                ),
                              ],
                            ),
                          ),
                          if (visit.status == VisitStatus.planned)
                            PhosphorIcon(
                              PhosphorIcons.checkCircle(PhosphorIconsStyle.duotone),
                              color: AppColors.primary,
                              size: 28,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // HIGH PRIORITY badge
          if (isHighPriority)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFBA1A1A), Color(0xFFFF5722)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFBA1A1A).withOpacity(0.4),
                      blurRadius: 8,
                    )
                  ],
                ),
                child: const Text(
                  'HIGH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Floating-style banner at the top of the Visits screen that lets
/// the MR jump straight into the Discovery Map.
class _DiscoverBanner extends StatelessWidget {
  const _DiscoverBanner();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.discoveryMap),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: PhosphorIcon(
                PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover Nearby Doctors',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Filter by specialty, rating & distance',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
