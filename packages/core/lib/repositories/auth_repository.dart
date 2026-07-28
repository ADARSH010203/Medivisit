import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> authStateChanges();
  User? getCurrentUser();
  Future<String?> getIdToken();
  Future<UserCredential> signIn(String email, String password);
  Future<UserCredential> signUp(String email, String password);
  Future<void> signOut();
  Future<void> updateProfile({String? displayName});
  
  // TODO: Phone MFA requires Blaze plan — implement after upgrade
  Future<void> enrollMfa(String phoneNumber);
  Future<bool> verifyMfa(String verificationId, String smsCode);
  Future<void> disableMfa();
}
