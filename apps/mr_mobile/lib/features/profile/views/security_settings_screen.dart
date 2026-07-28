import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Security & 2FA'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MeshGradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // App Check Status Card
            GlassCard(
              level: 2,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B5C).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: PhosphorIcon(
                      PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
                      color: const Color(0xFF006B5C),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Firebase App Check',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Active (Debug / Play Integrity)',
                          style: TextStyle(
                            color: Color(0xFF006B5C),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Two-Factor Authentication (2FA) Card
            GlassCard(
              level: 2,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0053D3).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: PhosphorIcon(
                          PhosphorIcons.lockKey(PhosphorIconsStyle.duotone),
                          color: const Color(0xFF0053D3),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Phone 2FA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8A800).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFE8A800).withOpacity(0.4)),
                                  ),
                                  child: const Text(
                                    '2FA Coming Soon',
                                    style: TextStyle(
                                      color: Color(0xFFB45309),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'SMS Verification Code on Login',
                              style: TextStyle(
                                color: Color(0xFF424655),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        PhosphorIcon(
                          PhosphorIcons.info(PhosphorIconsStyle.duotone),
                          color: Color(0xFF7A7582),
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            // TODO: Phone MFA requires Blaze plan — implement after upgrade
                            'Phone MFA requires Firebase Identity Platform (Blaze plan). This feature will be enabled upon plan upgrade.',
                            style: TextStyle(
                              color: Color(0xFF7A7582),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
