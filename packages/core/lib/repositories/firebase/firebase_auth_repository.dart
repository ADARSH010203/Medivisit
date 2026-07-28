import 'package:firebase_auth/firebase_auth.dart';
import '../auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<String?> getIdToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUp(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<void> updateProfile({String? displayName}) {
    return _firebaseAuth.currentUser!.updateDisplayName(displayName);
  }

  // TODO: Phone MFA requires Blaze plan — implement after upgrade
  @override
  Future<void> enrollMfa(String phoneNumber) async {
    // Stub implementation for Spark plan
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<bool> verifyMfa(String verificationId, String smsCode) async {
    // Stub implementation for Spark plan
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<void> disableMfa() async {
    // Stub implementation for Spark plan
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
