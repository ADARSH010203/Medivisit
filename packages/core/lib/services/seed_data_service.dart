import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SeedDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDefaultTerritory() async {
    final territoriesRef = _firestore.collection('territories');
    final snapshot = await territoriesRef.limit(1).get();

    if (snapshot.docs.isEmpty) {
      await territoriesRef.add({
        'name': 'Mumbai West',
        'region': 'Maharashtra',
        'officeLocation': const GeoPoint(19.0760, 72.8777),
        'mrCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Seeded default territory.');
    }
  }

  static Future<void> seedDefaultAdmin() async {
    if (!kDebugMode) return;

    try {
      const email = 'admin@medivisit.com';
      const password = 'Admin@123456';
      
      // Check if admin doc exists
      final query = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (query.docs.isNotEmpty) {
        debugPrint('Admin account already exists.');
        return;
      }

      // Create in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'name': 'System Admin',
          'email': email,
          'role': 'admin',
          'isVerified': true,
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('Seeded default admin account.');
      }
    } catch (e) {
      debugPrint('Failed to seed admin: $e');
    }
  }
}
