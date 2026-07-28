class BadgeDefinition {
  final String id;
  final String name;
  final String icon;
  final String criteriaType; // total_visits, streak, rating, etc.
  final int criteriaValue;

  BadgeDefinition({
    required this.id,
    required this.name,
    required this.icon,
    required this.criteriaType,
    required this.criteriaValue,
  });

  factory BadgeDefinition.fromJson(Map<String, dynamic> json, String id) {
    return BadgeDefinition(
      id: id,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      criteriaType: json['criteria_type'] ?? '',
      criteriaValue: json['criteria_value'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'criteria_type': criteriaType,
      'criteria_value': criteriaValue,
    };
  }
}
