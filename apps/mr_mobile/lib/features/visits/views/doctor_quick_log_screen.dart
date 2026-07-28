import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/doctor_quick_log_controller.dart';

class DoctorQuickLogScreen extends StatelessWidget {
  const DoctorQuickLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller here so we don't need a separate binding if we just navigate to it
    final controller = Get.put(DoctorQuickLogController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Doctor Visit'),
      ),
      body: MeshGradientBackground(
        child: SafeArea(
          child: Form(
            key: controller.formKey,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Log a visit instantly',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: const SliverToBoxAdapter(
                    child: Text(
                      'Search for an existing doctor or add a new one.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  
                  // Doctor Search & Selection
                  SliverToBoxAdapter(
                    child: GlassCard(
                      level: 1,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: controller.searchController,
                            decoration: InputDecoration(
                              hintText: 'Search doctor name or clinic...',
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: Obx(() {
                                if (controller.selectedDoctor.value != null || controller.isAddingNewDoctor.value) {
                                  return IconButton(
                                    icon: const Icon(Icons.clear_rounded),
                                    onPressed: () {
                                      controller.selectedDoctor.value = null;
                                      controller.isAddingNewDoctor.value = false;
                                      controller.searchController.clear();
                                      controller.searchDoctors('');
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              filled: true,
                              fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                            ),
                            onChanged: controller.searchDoctors,
                            onTap: () {
                              if (controller.selectedDoctor.value != null || controller.isAddingNewDoctor.value) {
                                controller.selectedDoctor.value = null;
                                controller.isAddingNewDoctor.value = false;
                                controller.searchController.clear();
                                controller.searchDoctors('');
                              }
                            },
                          ),
                          
                          Obx(() {
                            if (controller.selectedDoctor.value != null) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.success.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, color: AppColors.success),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Selected: ${controller.selectedDoctor.value!.name}',
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                                            ),
                                            Text(
                                              controller.selectedDoctor.value!.clinicName,
                                              style: TextStyle(color: AppColors.success.withOpacity(0.8), fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            
                            if (controller.isAddingNewDoctor.value) {
                              return const SizedBox.shrink(); // Will show new doctor form below
                            }

                            if (controller.filteredDoctors.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 24, bottom: 8),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Text('Doctor not found in system.'),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: controller.startAddingNewDoctor,
                                        icon: const Icon(Icons.person_add_rounded),
                                        label: const Text('Add New Doctor'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF7C5CFF),
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Container(
                              margin: const EdgeInsets.only(top: 8),
                              constraints: const BoxConstraints(maxHeight: 250),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: controller.filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  final doc = controller.filteredDoctors[index];
                                  return ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      child: Icon(Icons.person, color: AppColors.primary),
                                    ),
                                    title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${doc.specialty} • ${doc.clinicName}'),
                                    onTap: () => controller.selectDoctor(doc),
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  // Add New Doctor Form
                  Obx(() {
                    if (!controller.isAddingNewDoctor.value) return const SliverToBoxAdapter(child: SizedBox.shrink());
                    
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: GlassCard(
                          level: 1,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'New Doctor Details',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                controller: controller.doctorNameController,
                                label: 'Doctor Name *',
                                hint: 'Dr. First Last',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              DropdownButtonFormField<String>(
                                value: controller.selectedSpecialty.value,
                                decoration: InputDecoration(
                                  labelText: 'Specialty *',
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor.withOpacity(0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: controller.specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (v) {
                                  if (v != null) controller.selectedSpecialty.value = v;
                                },
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: controller.clinicNameController,
                                label: 'Clinic/Hospital Name *',
                                hint: 'E.g. City Hospital',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: controller.clinicAddressController,
                                label: 'Clinic Address *',
                                hint: 'Street, City, Area',
                                validator: (v) => v!.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: 12),
                              AppTextField(
                                controller: controller.phoneController,
                                label: 'Phone Number (Optional)',
                                hint: 'Mobile or Landline',
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  
                  // Location Capture
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: GlassCard(
                        level: 1,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.my_location_rounded, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'GPS Verification *',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              if (controller.isLocating.value) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              if (controller.gpsLocation.value == null) {
                                return ElevatedButton.icon(
                                  onPressed: controller.captureLocation,
                                  icon: const Icon(Icons.gps_fixed_rounded),
                                  label: const Text('Capture Current Location'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                  ),
                                );
                              }
                              
                              return Column(
                                children: [
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: FlutterMap(
                                      options: MapOptions(
                                        initialCenter: controller.pinLocation.value ?? controller.gpsLocation.value!,
                                        initialZoom: 16.0,
                                        onTap: (tapPosition, point) => controller.updatePinLocation(point),
                                      ),
                                      children: [
                                        ColorFiltered(
                                          colorFilter: const ColorFilter.matrix([
                                            -1,  0,  0, 0, 255,
                                             0, -1,  0, 0, 255,
                                             0,  0, -1, 0, 255,
                                             0,  0,  0, 1,   0,
                                          ]),
                                          child: TileLayer(
                                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName: 'com.medivisit.pro',
                                          ),
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            // Actual GPS location
                                            Marker(
                                              point: controller.gpsLocation.value!,
                                              child: const Icon(Icons.my_location_rounded, color: Colors.blue, size: 24),
                                            ),
                                            // Dropped pin
                                            Marker(
                                              point: controller.pinLocation.value!,
                                              child: const Icon(Icons.location_on_rounded, color: Colors.red, size: 40),
                                              alignment: Alignment.topCenter,
                                            ),
                                          ],
                                        ),
                                        if (controller.gpsLocation.value != null)
                                          CircleLayer(
                                            circles: [
                                              CircleMarker(
                                                point: controller.gpsLocation.value!,
                                                radius: 50,
                                                useRadiusInMeter: true,
                                                color: Colors.blue.withOpacity(0.1),
                                                borderColor: Colors.blue.withOpacity(0.5),
                                                borderStrokeWidth: 1,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Tap map to adjust pin within 50m if needed',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Notes
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: GlassCard(
                        level: 1,
                        padding: const EdgeInsets.all(20),
                        child: AppTextField(
                          controller: controller.notesController,
                          label: 'Visit Notes',
                          hint: 'Discussion points, sample drops, etc.',
                          maxLines: 3,
                        ),
                      ),
                    ),
                  ),

                  // Submit Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 40),
                      child: Obx(() => GradientButton(
                        text: 'Submit Visit',
                        isLoading: controller.isLoading.value,
                        onPressed: (controller.selectedDoctor.value != null || controller.isAddingNewDoctor.value) && controller.gpsLocation.value != null
                            ? () => controller.submitQuickVisit()
                            : null,
                        colors: const [Color(0xFF7C5CFF), AppColors.primary],
                      )),
                    ),
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
