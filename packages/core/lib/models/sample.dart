import 'package:cloud_firestore/cloud_firestore.dart';

class Sample {
  final String id;
  final String mrId;
  final String productId;
  final String productName;
  final String doctorId;
  final String doctorName;
  final int quantity;
  final String? visitId;
  final DateTime? loggedAt;

  Sample({
    required this.id,
    required this.mrId,
    required this.productId,
    required this.productName,
    required this.doctorId,
    required this.doctorName,
    required this.quantity,
    this.visitId,
    this.loggedAt,
  });

  factory Sample.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Sample(
      id: doc.id,
      mrId: data['mr_id'] ?? '',
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      doctorId: data['doctor_id'] ?? '',
      doctorName: data['doctor_name'] ?? '',
      quantity: data['quantity'] ?? 0,
      visitId: data['visit_id'],
      loggedAt: data['logged_at'] != null ? (data['logged_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mr_id': mrId,
      'product_id': productId,
      'product_name': productName,
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'quantity': quantity,
      if (visitId != null) 'visit_id': visitId,
      if (loggedAt != null) 'logged_at': Timestamp.fromDate(loggedAt!),
    };
  }
}
