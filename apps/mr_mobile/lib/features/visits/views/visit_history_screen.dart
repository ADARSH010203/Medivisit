import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/visit_history_controller.dart';

class VisitHistoryScreen extends StatelessWidget {
  const VisitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisitHistoryController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Visit History'),
        centerTitle: true,
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.pastVisits.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                    ).createShader(b),
                    child: PhosphorIcon(
                      PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.duotone),
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('No visits yet',
                      style: TextStyle(fontSize: 16, color: Color(0xFF7A7582))),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.pastVisits.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final visit = controller.pastVisits[index];
              final rating = (visit['rating'] ?? 0) as int;
              return GlassCard(
                level: 2,
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left gradient accent bar
                      Container(
                        width: 4,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF006B5C), Color(0xFF44DDC1)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
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
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0053D3).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: PhosphorIcon(
                                  PhosphorIcons.user(PhosphorIconsStyle.duotone),
                                  color: const Color(0xFF0053D3),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      visit['doctorName'] ?? 'Doctor',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${visit['date']} • ${visit['time']}',
                                      style: const TextStyle(
                                          color: Color(0xFF424655), fontSize: 12),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: List.generate(5, (i) {
                                        return PhosphorIcon(
                                          i < rating
                                              ? PhosphorIcons.star(PhosphorIconsStyle.fill)
                                              : PhosphorIcons.star(PhosphorIconsStyle.regular),
                                          color: const Color(0xFFE8A800),
                                          size: 14,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              PhosphorIcon(
                                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                                color: const Color(0xFF424655),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
