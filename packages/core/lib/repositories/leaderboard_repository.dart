import '../models/leaderboard_entry.dart';

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntry>> getWeeklyLeaderboard();
  
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard();
  
  Future<LeaderboardEntry?> getMrRank(String mrId, String period);
}
