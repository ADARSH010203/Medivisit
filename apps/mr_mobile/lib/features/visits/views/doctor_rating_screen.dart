import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import '../controllers/visits_controller.dart';
import '../../../app/routes.dart';

class DoctorRatingScreen extends StatefulWidget {
  const DoctorRatingScreen({super.key});

  @override
  State<DoctorRatingScreen> createState() => _DoctorRatingScreenState();
}

class _DoctorRatingScreenState extends State<DoctorRatingScreen> {
  final VisitsController _controller = Get.find<VisitsController>();
  int _rating = 0;
  final TextEditingController _notesController = TextEditingController();
  final List<String> _availableTags = [
    'Doctor Unavailable', 'Sample Dropped', 'Prescription Generated', 
    'Detailed Discussion', 'Follow-up Requested', 'Competitor mentioned'
  ];
  final Set<String> _selectedTags = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Visit'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.offAllNamed(AppRoutes.dashboard),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How was the visit?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  iconSize: 48,
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: index < _rating ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 32),
            const Text('Tags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text('Notes (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: 'Notes',
              hint: 'Enter any additional details about the visit...',
              maxLines: 4,
            ),
            const SizedBox(height: 48),
            Obx(() => GradientButton(
              text: 'Submit Feedback',
              isLoading: _controller.isLoading.value,
              onPressed: () async {
                if (_rating == 0) {
                  Get.snackbar('Required', 'Please provide a star rating');
                  return;
                }
                
                // Usually we'd pass the actual visit ID here, but for now we find the most recently completed one or similar.
                // Assuming `_controller.currentVisits` has the completed visit, or we can just pass the data to controller.
                // For this UI mockup, we will just simulate success.
                await Future.delayed(const Duration(seconds: 1));
                Get.snackbar('Success', 'Feedback submitted successfully');
                Get.offAllNamed(AppRoutes.dashboard);
              },
            )),
          ],
        ),
      ),
    );
  }
}
