class LeaderboardEntry {
  final String mrId;
  final String name;
  final String territory;
  final int score;
  final int rank;
  final int? rankDelta;

  LeaderboardEntry({
    required this.mrId,
    required this.name,
    required this.territory,
    required this.score,
    required this.rank,
    this.rankDelta,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      mrId: json['mr_id'] ?? '',
      name: json['name'] ?? '',
      territory: json['territory'] ?? '',
      score: json['score'] ?? 0,
      rank: json['rank'] ?? 0,
      rankDelta: json['rank_delta'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mr_id': mrId,
      'name': name,
      'territory': territory,
      'score': score,
      'rank': rank,
      if (rankDelta != null) 'rank_delta': rankDelta,
    };
  }
}
