import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:core/core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/visits_controller.dart';
import '../../../app/routes.dart';

class ConfirmLocationScreen extends StatefulWidget {
  const ConfirmLocationScreen({super.key});

  @override
  State<ConfirmLocationScreen> createState() => _ConfirmLocationScreenState();
}

class _ConfirmLocationScreenState extends State<ConfirmLocationScreen> {
  final VisitsController _controller = Get.find<VisitsController>();
  late Doctor doctor;
  late Visit visit;
  
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  double _distanceToDoctor = 0;
  bool _isGeofenceException = false;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    doctor = Get.arguments as Doctor;
    
    // Find the corresponding planned visit for today
    visit = _controller.currentVisits.firstWhere(
      (v) => v.doctorId == doctor.id && v.status == VisitStatus.planned,
      orElse: () => Visit(
        id: 'new_visit', mrId: 'current', doctorId: doctor.id, doctorName: doctor.name, 
        visitDate: 'today', visitTime: 'now', dayOfWeek: 'now', feedbackTags: [], 
        geofenceVerified: false, status: VisitStatus.planned,
      )
    );

    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        setState(() {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
          if (doctor.clinicLocation.latitude != 0 && doctor.clinicLocation.longitude != 0) {
            _distanceToDoctor = _calculateDistance(
              _currentLocation!.latitude, _currentLocation!.longitude,
              doctor.clinicLocation.latitude, doctor.clinicLocation.longitude
            );
            _isGeofenceException = _distanceToDoctor > 150;
          }
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      Get.snackbar('Location Error', e.toString());
      setState(() => _isLoadingLocation = false);
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - 
        (lat2 - lat1 * p).abs() / 2 +
        (lat1 * p).abs() * (lat2 * p).abs() * (1 - (lon2 - lon1 * p).abs()) / 2;
    return 12742 * (a * a).abs() * 1000; // Returns meters approx.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Location')),
      body: _isLoadingLocation 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentLocation ?? LatLng(doctor.clinicLocation.latitude, doctor.clinicLocation.longitude),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.medivisit.pro',
                    ),
                    MarkerLayer(
                      markers: [
                        if (doctor.clinicLocation.latitude != 0)
                          Marker(
                            point: LatLng(doctor.clinicLocation.latitude, doctor.clinicLocation.longitude),
                            child: const Icon(Icons.local_hospital, color: Colors.red, size: 40),
                          ),
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            child: const Icon(Icons.person_pin_circle, color: AppColors.primary, size: 40),
                          ),
                      ],
                    ),
                    if (doctor.clinicLocation.latitude != 0)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(doctor.clinicLocation.latitude, doctor.clinicLocation.longitude),
                            radius: 150,
                            useRadiusInMeter: true,
                            color: Colors.red.withOpacity(0.2),
                            borderColor: Colors.red,
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isGeofenceException) ...[
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('Outside Geofence (150m)', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _notesController,
                        label: 'Exception Reason',
                        hint: 'Enter exception reason (e.g. Doctor is in surgery)',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                    ],
                    Obx(() => GradientButton(
                      text: 'Confirm Visit',
                      isLoading: _controller.isLoading.value,
                      onPressed: () async {
                        if (_isGeofenceException && _notesController.text.isEmpty) {
                          Get.snackbar('Required', 'Please enter an exception reason');
                          return;
                        }
                        await _controller.confirmVisitLocation(visit, _notesController.text, _isGeofenceException);
                        Get.offNamed(AppRoutes.visitSuccess);
                      },
                    )),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
