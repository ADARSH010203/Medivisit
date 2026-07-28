import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final String dosage;
  final String? imageUrl;
  final String? brochureUrl;
  final bool isAvailable;
  final int stockLevel;
  final int reorderThreshold;
  final double price;
  final String? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.dosage,
    this.imageUrl,
    this.brochureUrl,
    required this.isAvailable,
    required this.stockLevel,
    required this.reorderThreshold,
    required this.price,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      dosage: data['dosage'] ?? '',
      imageUrl: data['image_url'],
      brochureUrl: data['brochure_url'],
      isAvailable: data['is_available'] ?? true,
      stockLevel: data['stock_level'] ?? 0,
      reorderThreshold: data['reorder_threshold'] ?? 10,
      price: (data['price'] ?? 0.0).toDouble(),
      expiryDate: data['expiry_date'],
      createdAt: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
      updatedAt: data['updated_at'] != null ? (data['updated_at'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'dosage': dosage,
      if (imageUrl != null) 'image_url': imageUrl,
      if (brochureUrl != null) 'brochure_url': brochureUrl,
      'is_available': isAvailable,
      'stock_level': stockLevel,
      'reorder_threshold': reorderThreshold,
      'price': price,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (createdAt != null) 'created_at': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? dosage,
    String? imageUrl,
    String? brochureUrl,
    bool? isAvailable,
    int? stockLevel,
    int? reorderThreshold,
    double? price,
    String? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      dosage: dosage ?? this.dosage,
      imageUrl: imageUrl ?? this.imageUrl,
      brochureUrl: brochureUrl ?? this.brochureUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      stockLevel: stockLevel ?? this.stockLevel,
      reorderThreshold: reorderThreshold ?? this.reorderThreshold,
      price: price ?? this.price,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
