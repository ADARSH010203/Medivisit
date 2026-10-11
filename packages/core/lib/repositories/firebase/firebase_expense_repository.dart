import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../expense_repository.dart';
import '../../models/expense.dart';
import '../../services/offline_sync_service.dart';
import '../../services/cloudinary_service.dart';

class FirebaseExpenseRepository implements ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseExpenseRepository() {
    if (Get.isRegistered<OfflineSyncService>()) {
      Get.find<OfflineSyncService>().registerHandler('submit_expense', (payload) async {
        final id = payload.remove('_doc_id') as String?;
        if (id == null || id.isEmpty) return;
        
        // Intercept local image upload
        if (payload['receipt_image_url'] != null) {
          final imageUrl = payload['receipt_image_url'] as String;
          final isLocal = !imageUrl.startsWith('http://') && !imageUrl.startsWith('https://');
          if (isLocal) {
            final syncService = Get.find<OfflineSyncService>();
            
            final secureUrl = await CloudinaryService.uploadImage(
              imageUrl, 
              'expenses',
              onProgress: (progress) {
                syncService.updateImageProgress(id, progress);
              },
            );
            
            if (secureUrl != null) {
              payload['receipt_image_url'] = secureUrl;
            } else {
              throw Exception('Failed to upload receipt image to Cloudinary');
            }
          }
        }
        
        await _firestore.collection('expenses').doc(id).set(payload);
      });
    }
  }

  @override
  Future<void> submitExpense(Expense expense) async {
    final docRef = _firestore.collection('expenses').doc(
      expense.id.isNotEmpty ? expense.id : null,
    );
    
    final data = expense.toFirestore();
    data['created_at'] = FieldValue.serverTimestamp();
    
    if (Get.isRegistered<OfflineSyncService>()) {
      final payload = Map<String, dynamic>.from(data);
      payload['_doc_id'] = docRef.id;
      await Get.find<OfflineSyncService>().queueAction('submit_expense', payload);
    } else {
      await docRef.set(data);
    }
  }

  @override
  Future<List<Expense>> getExpenses(String mrId) async {
    final snapshot = await _firestore.collection('expenses')
        .where('mr_id', isEqualTo: mrId)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  @override
  Future<List<Expense>> getPendingExpenses() async {
    final snapshot = await _firestore.collection('expenses')
        .where('status', isEqualTo: 'pending')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateExpenseStatus(String expenseId, ExpenseStatus status, {String? approvedBy}) async {
    final statusStr = status == ExpenseStatus.approved ? 'approved' : 'rejected';
    await _firestore.collection('expenses').doc(expenseId).update({
      'status': statusStr,
      'approved_at': FieldValue.serverTimestamp(),
      if (approvedBy != null) 'approved_by': approvedBy,
    });
  }
}
