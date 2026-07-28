import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';

import '../../controllers/doctor_filter_controller.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DoctorFilterController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.adminSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discovery Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    controller.updateFilter(const DoctorFilterModel());
                  },
                  child: const Text('Reset', style: TextStyle(color: AppColors.warning)),
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
                    _buildSectionTitle('Map Layer'),
                    const SizedBox(height: 12),
                    _buildMapLayers(filter, controller),
                    
                    const SizedBox(height: 24),
                    _buildSectionTitle('Sort By'),
                    const SizedBox(height: 12),
                    _buildSortOptions(filter, controller),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Specialties'),
                    const SizedBox(height: 12),
                    _buildSpecialties(filter, controller),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Distance (${filter.distanceKm.toInt()} km)'),
                    const SizedBox(height: 8),
                    Slider(
                      value: filter.distanceKm,
                      min: 1,
                      max: 25,
                      divisions: 24,
                      activeColor: AppColors.primary,
                      onChanged: (v) {
                        controller.updateFilter(filter.copyWith(distanceKm: v));
                      },
                    ),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Minimum Rating'),
                    const SizedBox(height: 12),
                    _buildRating(filter, controller),

                    const SizedBox(height: 24),
                    _buildSectionTitle('Availability'),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Available Today'),
                      value: filter.availableToday,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        controller.updateFilter(filter.copyWith(availableToday: v));
                      },
                    ),
                    SwitchListTile(
                      title: const Text('High Priority Only'),
                      value: filter.highPriorityOnly,
                      activeColor: AppColors.tertiary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) {
                        controller.updateFilter(filter.copyWith(highPriorityOnly: v));
                      },
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
    );
  }

  Widget _buildMapLayers(DoctorFilterModel filter, DoctorFilterController controller) {
    return Row(
      children: [
        _buildChoiceChip('Standard', filter.mapLayer == MapLayerType.standard, () {
          controller.updateFilter(filter.copyWith(mapLayer: MapLayerType.standard));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('Satellite', filter.mapLayer == MapLayerType.satellite, () {
          controller.updateFilter(filter.copyWith(mapLayer: MapLayerType.satellite));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('Terrain', filter.mapLayer == MapLayerType.terrain, () {
          controller.updateFilter(filter.copyWith(mapLayer: MapLayerType.terrain));
        }),
      ],
    );
  }

  Widget _buildSortOptions(DoctorFilterModel filter, DoctorFilterController controller) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChoiceChip('Nearest', filter.sortBy == SortOption.nearest, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.nearest));
        }),
        _buildChoiceChip('Highest Rated', filter.sortBy == SortOption.highestRated, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.highestRated));
        }),
        _buildChoiceChip('Most Visited', filter.sortBy == SortOption.mostVisited, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.mostVisited));
        }),
        _buildChoiceChip('High Priority First', filter.sortBy == SortOption.highPriorityFirst, () {
          controller.updateFilter(filter.copyWith(sortBy: SortOption.highPriorityFirst));
        }),
      ],
    );
  }

  Widget _buildSpecialties(DoctorFilterModel filter, DoctorFilterController controller) {
    final allSpecialties = ['Cardiologist', 'Dermatologist', 'Pediatrician', 'Neurologist', 'Orthopedic'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allSpecialties.map((s) {
        final isSelected = filter.specialties.contains(s);
        return FilterChip(
          label: Text(s),
          selected: isSelected,
          onSelected: (selected) {
            final list = List<String>.from(filter.specialties);
            if (selected) list.add(s);
            else list.remove(s);
            controller.updateFilter(filter.copyWith(specialties: list));
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }).toList(),
    );
  }

  Widget _buildRating(DoctorFilterModel filter, DoctorFilterController controller) {
    return Row(
      children: [
        _buildChoiceChip('3.0+', filter.minRating == 3.0, () {
          controller.updateFilter(filter.copyWith(minRating: 3.0));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('4.0+', filter.minRating == 4.0, () {
          controller.updateFilter(filter.copyWith(minRating: 4.0));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('4.5+', filter.minRating == 4.5, () {
          controller.updateFilter(filter.copyWith(minRating: 4.5));
        }),
        const SizedBox(width: 8),
        _buildChoiceChip('5.0', filter.minRating == 5.0, () {
          controller.updateFilter(filter.copyWith(minRating: 5.0));
        }),
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
      side: BorderSide(color: isSelected ? AppColors.primary : Colors.grey[400]!),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: onTap,
    );
  }
}
