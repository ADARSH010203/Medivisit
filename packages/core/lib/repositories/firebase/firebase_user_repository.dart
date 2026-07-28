import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/mr_user.dart';
import '../user_repository.dart';

class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<MrUser?> getUserById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return MrUser.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> createUser(MrUser user) {
    return _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    data['updated_at'] = FieldValue.serverTimestamp();
    return _firestore.collection('users').doc(uid).update(data);
  }

  @override
  Stream<MrUser?> streamUser(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return MrUser.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<void> verifyUser(String uid, bool isVerified) {
    return updateUser(uid, {'is_verified': isVerified});
  }

  @override
  Future<void> blockUser(String uid, bool isBlocked) {
    return updateUser(uid, {'is_blocked': isBlocked});
  }

  @override
  Future<List<MrUser>> getUnverifiedUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'mr')
        .where('is_verified', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) => MrUser.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MrUser>> getAllMrs() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'mr')
        .get();
    return snapshot.docs.map((doc) => MrUser.fromFirestore(doc)).toList();
  }
}
