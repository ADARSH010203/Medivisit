import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../controllers/profile_controller.dart';
import '../../../app/routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.duotone),
                color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.editProfile),
          ),
        ],
      ),
      body: MeshGradientBackground(
        child: Obx(() {
          final data = controller.profileData;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
            children: [
              // ── Avatar with gradient ring ──
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 104,
                      height: 104,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1D1B20)
                                : const Color(0xFFEADDFF),
                          ),
                          child: Center(
                            child: Text(
                              (data['name'] as String).isNotEmpty
                                  ? (data['name'] as String)[0].toUpperCase()
                                  : 'M',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0053D3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Name
              Center(
                child: Text(
                  data['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              const SizedBox(height: 4),
              // Email with gradient
              Center(
                child: Text(
                  data['email'] as String,
                  style: const TextStyle(color: Color(0xFF424655), fontSize: 14),
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats row with gradient numbers ──
              Row(
                children: [
                  _StatCard(
                    icon: PhosphorIcons.stethoscope(PhosphorIconsStyle.duotone),
                    iconColor: const Color(0xFF0053D3),
                    value: '${data['totalVisits']}',
                    label: 'Total Visits',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: PhosphorIcons.trendUp(PhosphorIconsStyle.duotone),
                    iconColor: const Color(0xFF006B5C),
                    value: data['successRate'] as String,
                    label: 'Success Rate',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: PhosphorIcons.trophy(PhosphorIconsStyle.duotone),
                    iconColor: const Color(0xFFB45309),
                    value: '${data['rank'] ?? '#4'}',
                    label: 'Rank',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Account Info ──
              Text(
                'Account Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1D1B20),
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                level: 2,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    _buildInfoRow(
                      PhosphorIcons.phone(PhosphorIconsStyle.duotone),
                      'Phone',
                      data['phone'] as String,
                    ),
                    Divider(height: 1, color: Colors.white.withOpacity(0.3)),
                    _buildInfoRow(
                      PhosphorIcons.mapPin(PhosphorIconsStyle.duotone),
                      'Region',
                      data['region'] as String,
                    ),
                    Divider(height: 1, color: Colors.white.withOpacity(0.3)),
                    _buildInfoRow(
                      PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
                      'Status',
                      data['status'] as String,
                      valueColor: const Color(0xFF006B5C),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GradientButton(
                text: 'Sync Now',
                onPressed: () async {
                  final syncService = Get.find<OfflineSyncService>();
                  await syncService.retryFailedActions();
                  Get.snackbar('Sync Complete', 'Offline data sync triggered.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black87,
                      colorText: Colors.white);
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Security & 2FA',
                onPressed: () => Get.toNamed(AppRoutes.securitySettings),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Edit Profile',
                onPressed: () => Get.toNamed(AppRoutes.editProfile),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Logout',
                onPressed: controller.logout,
              ),
            ],
          );
        }),
      ),
      bottomNavigationBar: PillBottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Get.toNamed(AppRoutes.dashboard);
          if (index == 1) Get.toNamed(AppRoutes.visits);
          if (index == 2) Get.toNamed(AppRoutes.catalog);
        },
      ),
    );
  }

  Widget _buildInfoRow(
    PhosphorIconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          PhosphorIcon(icon, color: const Color(0xFF424655), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Color(0xFF424655), fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final PhosphorIconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        level: 2,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            PhosphorIcon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF0053D3), Color(0xFF44DDC1)],
              ).createShader(bounds),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF424655),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
