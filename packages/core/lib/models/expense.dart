import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseStatus { pending, approved, rejected }

class Expense {
  final String id;
  final String mrId;
  final String category;
  final String vendor;
  final double amount;
  final String currency;
  final String expenseDate;
  final String? receiptImageUrl;
  final String? ocrRawText;
  final String? notes;
  final ExpenseStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;
  final DateTime? createdAt;

  Expense({
    required this.id,
    required this.mrId,
    required this.category,
    required this.vendor,
    required this.amount,
    required this.currency,
    required this.expenseDate,
    this.receiptImageUrl,
    this.ocrRawText,
    this.notes,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    ExpenseStatus statusVal = ExpenseStatus.pending;
    switch (data['status']) {
      case 'approved':
        statusVal = ExpenseStatus.approved;
        break;
      case 'rejected':
        statusVal = ExpenseStatus.rejected;
        break;
    }

    return Expense(
      id: doc.id,
      mrId: data['mr_id'] ?? '',
      category: data['category'] ?? '',
      vendor: data['vendor'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'INR',
      expenseDate: data['expense_date'] ?? '',
      receiptImageUrl: data['receipt_image_url'],
      ocrRawText: data['ocr_raw_text'],
      notes: data['notes'],
      status: statusVal,
      approvedBy: data['approved_by'],
      approvedAt: data['approved_at'] != null ? (data['approved_at'] as Timestamp).toDate() : null,
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    String statusStr = 'pending';
    switch (status) {
      case ExpenseStatus.approved:
        statusStr = 'approved';
        break;
      case ExpenseStatus.rejected:
        statusStr = 'rejected';
        break;
      case ExpenseStatus.pending:
        statusStr = 'pending';
        break;
    }

    return {
      'mr_id': mrId,
      'category': category,
      'vendor': vendor,
      'amount': amount,
      'currency': currency,
      'expense_date': expenseDate,
      if (receiptImageUrl != null) 'receipt_image_url': receiptImageUrl,
      if (ocrRawText != null) 'ocr_raw_text': ocrRawText,
      if (notes != null) 'notes': notes,
      'status': statusStr,
      if (approvedBy != null) 'approved_by': approvedBy,
      if (approvedAt != null) 'approved_at': Timestamp.fromDate(approvedAt!),
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
    };
  }
}
