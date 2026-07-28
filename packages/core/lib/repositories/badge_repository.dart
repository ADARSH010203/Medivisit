import '../models/badge_definition.dart';

abstract class BadgeRepository {
  Future<List<BadgeDefinition>> getBadgeDefinitions();
  
  Future<List<String>> getMrBadges(String mrId);
  
  Future<List<BadgeDefinition>> checkAndAwardBadges(String mrId);
}
