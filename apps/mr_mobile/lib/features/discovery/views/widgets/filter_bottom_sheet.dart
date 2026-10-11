import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../controllers/doctor_filter_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorFilterController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF151C27) : Colors.white;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: surfaceColor.withOpacity(0.78),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
                width: 1.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Discovery Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1D1B20),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        controller.updateFilter(const DoctorFilterModel());
                      },
                      icon: PhosphorIcon(
                        PhosphorIcons.arrowCounterClockwise(),
                        size: 16,
                        color: AppColors.warning,
                      ),
                      label: const Text(
                        'Reset',
                        style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Obx(() {
                    final filter = controller.filter.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Map Layer', isDark),
                        const SizedBox(height: 12),
                        _buildMapLayers(filter, controller, isDark),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Sort By', isDark),
                        const SizedBox(height: 12),
                        _buildSortOptions(filter, controller, isDark),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Specialties', isDark),
                        const SizedBox(height: 12),
                        _buildSpecialties(filter, controller, isDark),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Distance (${filter.distanceKm.toInt()} km)', isDark),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderThemeData(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: AppColors.primary.withOpacity(0.15),
                            thumbColor: AppColors.primary,
                            overlayColor: AppColors.primary.withOpacity(0.1),
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            value: filter.distanceKm,
                            min: 1,
                            max: 25,
                            divisions: 24,
                            onChanged: (v) {
                              controller.updateFilter(filter.copyWith(distanceKm: v));
                            },
                          ),
                        ),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Minimum Rating', isDark),
                        const SizedBox(height: 12),
                        _buildRating(filter, controller, isDark),

                        const SizedBox(height: 24),
                        _buildSectionTitle('Availability', isDark),
                        const SizedBox(height: 12),
                        GlassCard(
                          level: 1,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(
                                  'Available Today',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1D1B20),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: filter.availableToday,
                                activeColor: AppColors.primary,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                onChanged: (v) {
                                  controller.updateFilter(filter.copyWith(availableToday: v));
                                },
                              ),
                              Divider(
                                height: 1,
                                color: isDark ? Colors.white10 : Colors.grey[200],
                              ),
                              SwitchListTile(
                                title: Text(
                                  'High Priority Only',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF1D1B20),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: filter.highPriorityOnly,
                                activeColor: AppColors.tertiary,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                onChanged: (v) {
                                  controller.updateFilter(filter.copyWith(highPriorityOnly: v));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40), // Bottom padding
                      ],
                    );
                  }),
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GradientButton(
                  text: 'Apply Filters',
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white60 : const Color(0xFF494551),
      ),
    );
  }

  Widget _buildMapLayers(DoctorFilterModel filter, DoctorFilterController controller, bool isDark) {
    return Row(
      children: [
        _buildChoiceChip('Standard', filter.mapLayer == MapLayerType.standard, isDark, () {
          controller.updateFilter(filter.copyWith(mapLayer: MapLayerType.standard));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('Satellite', filter.mapLayer == MapLayerType.satellite, isDark, () {
          controller.updateFilter(filter.copyWith(mapLayer: MapLayerType.satellite));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('Terrain', filter.mapLayer == MapLayerType.terrain, isDark, () {
          controller.updateFilter(filter.copyWith(mapLayer: MapLayerType.terrain));
        }),
      ],
    );
  }

  Widget _buildSortOptions(DoctorFilterModel filter, DoctorFilterController controller, bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChoiceChip('Nearest', filter.sortBy == SortOption.nearest, isDark, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.nearest));
        }),
        _buildChoiceChip('Highest Rated', filter.sortBy == SortOption.highestRated, isDark, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.highestRated));
        }),
        _buildChoiceChip('Most Visited', filter.sortBy == SortOption.mostVisited, isDark, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.mostVisited));
        }),
        _buildChoiceChip('High Priority First', filter.sortBy == SortOption.highPriorityFirst, isDark, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.highPriorityFirst));
        }),
      ],
    );
  }

  Widget _buildSpecialties(DoctorFilterModel filter, DoctorFilterController controller, bool isDark) {
    // Hardcoded specialty list — safe: these are display labels, not user-controlled input.
    // They are matched against server-side specialty strings in the Doctor model.
    const allSpecialties = ['Cardiologist', 'Dermatologist', 'Pediatrician', 'Neurologist', 'Orthopedic'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allSpecialties.map((s) {
        final isSelected = filter.specialties.contains(s);
        return FilterChip(
          label: Text(
            s,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF494551)),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            final list = List<String>.from(filter.specialties);
            if (selected) {
              list.add(s);
            } else {
              list.remove(s);
            }
            controller.updateFilter(filter.copyWith(specialties: list));
          },
          selectedColor: AppColors.primary,
          backgroundColor: isDark ? Colors.white.withOpacity(0.08) : Colors.grey[100],
          checkmarkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white24 : Colors.grey[300]!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRating(DoctorFilterModel filter, DoctorFilterController controller, bool isDark) {
    return Row(
      children: [
        _buildChoiceChip('3.0+', filter.minRating == 3.0, isDark, () {
          controller.updateFilter(filter.copyWith(minRating: 3.0));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('4.0+', filter.minRating == 4.0, isDark, () {
          controller.updateFilter(filter.copyWith(minRating: 4.0));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('4.5+', filter.minRating == 4.5, isDark, () {
          controller.updateFilter(filter.copyWith(minRating: 4.5));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('5.0', filter.minRating == 5.0, isDark, () {
          controller.updateFilter(filter.copyWith(minRating: 5.0));
        }),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, bool isDark, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : const Color(0xFF494551)),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected
          ? AppColors.primary
          : (isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
      side: BorderSide(
        color: isSelected
            ? AppColors.primary
            : (isDark ? Colors.white24 : Colors.grey[400]!),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}
