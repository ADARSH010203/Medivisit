import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../models/mr_user.dart';

class AuthService {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AuthService(this._authRepo, this._userRepo);

  Future<MrUser?> signIn(String email, String password) async {
    final credential = await _authRepo.signIn(email, password);
    if (credential.user != null) {
      return await _userRepo.getUserById(credential.user!.uid);
    }
    return null;
  }

  Future<MrUser?> signUpAndCreateRecord(String email, String password, String name, String phone, String territoryId) async {
    final credential = await _authRepo.signUp(email, password);
    final user = credential.user;
    if (user != null) {
      await _authRepo.updateProfile(displayName: name);
      
      final mrUser = MrUser(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'mr',
        isVerified: false,
        isBlocked: false,
        territoryId: territoryId,
        language: 'en',
        darkMode: false,
        attendanceStreak: 0,
        totalVisits: 0,
        avgRating: 0.0,
        fcmTokens: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _userRepo.createUser(mrUser);
      return mrUser;
    }
    return null;
  }

  Future<void> signOut() {
    return _authRepo.signOut();
  }

  Future<MrUser?> getFreshUserRecord() async {
    final user = _authRepo.getCurrentUser();
    if (user != null) {
      return await _userRepo.getUserById(user.uid);
    }
    return null;
  }
}
