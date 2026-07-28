import '../models/mr_user.dart';

abstract class UserRepository {
  Future<MrUser?> getUserById(String uid);
  Future<void> createUser(MrUser user);
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  Stream<MrUser?> streamUser(String uid);
  Future<void> verifyUser(String uid, bool isVerified);
  Future<void> blockUser(String uid, bool isBlocked);
  Future<List<MrUser>> getUnverifiedUsers();
  Future<List<MrUser>> getAllMrs();
}
