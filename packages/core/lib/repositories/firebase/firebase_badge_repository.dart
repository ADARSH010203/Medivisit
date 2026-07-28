import 'package:cloud_firestore/cloud_firestore.dart';
import '../badge_repository.dart';
import '../../models/badge_definition.dart';

class FirebaseBadgeRepository implements BadgeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<BadgeDefinition>> getBadgeDefinitions() async {
    final snapshot = await _firestore.collection('badges').get();
    return snapshot.docs.map((doc) => BadgeDefinition.fromJson(doc.data(), doc.id)).toList();
  }

  @override
  Future<List<String>> getMrBadges(String mrId) async {
    final doc = await _firestore.collection('mr_badges').doc(mrId).get();
    if (!doc.exists) return [];
    
    final data = doc.data() as Map<String, dynamic>;
    final badgeIds = data['earned_badges'] as List<dynamic>? ?? [];
    return badgeIds.map((e) => e.toString()).toList();
  }

  @override
  Future<List<BadgeDefinition>> checkAndAwardBadges(String mrId) async {
    // In a real app, this logic might run via Edge Functions when a visit is completed.
    // For now, we simulate checking logic client-side or returning newly unlocked ones.
    return [];
  }
}
