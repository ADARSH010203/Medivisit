import 'package:cloud_firestore/cloud_firestore.dart';
import '../leaderboard_repository.dart';
import '../../models/leaderboard_entry.dart';

class FirebaseLeaderboardRepository implements LeaderboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard() async {
    return _getLeaderboardSnapshot('weekly');
  }

  @override
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard() async {
    return _getLeaderboardSnapshot('monthly');
  }

  @override
  Future<LeaderboardEntry?> getMrRank(String mrId, String period) async {
    final entries = await _getLeaderboardSnapshot(period);
    try {
      return entries.firstWhere((e) => e.mrId == mrId);
    } catch (e) {
      return null; // Not found
    }
  }

  Future<List<LeaderboardEntry>> _getLeaderboardSnapshot(String period) async {
    final doc = await _firestore.collection('leaderboard_snapshots').doc(period).get();
    if (!doc.exists) return [];
    
    final data = doc.data() as Map<String, dynamic>;
    final rankings = data['rankings'] as List<dynamic>? ?? [];
    
    return rankings.map((r) => LeaderboardEntry.fromJson(r as Map<String, dynamic>)).toList();
  }
}
