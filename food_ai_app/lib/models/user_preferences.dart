class UserPreferences {
  final String userId;
  final List<String> dietaryRestrictions;
  final List<String> favoriteCuisines;
  final List<String> allergies;
  final String? spiceLevel;
  final String? budgetRange;

  UserPreferences({
    required this.userId,
    this.dietaryRestrictions = const [],
    this.favoriteCuisines = const [],
    this.allergies = const [],
    this.spiceLevel,
    this.budgetRange,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['user_id'] ?? '',
      dietaryRestrictions: List<String>.from(json['dietary_restrictions'] ?? []),
      favoriteCuisines: List<String>.from(json['favorite_cuisines'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      spiceLevel: json['spice_level'],
      budgetRange: json['budget_range'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'dietary_restrictions': dietaryRestrictions,
      'favorite_cuisines': favoriteCuisines,
      'allergies': allergies,
      'spice_level': spiceLevel,
      'budget_range': budgetRange,
    };
  }

  UserPreferences copyWith({
    String? userId,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCuisines,
    List<String>? allergies,
    String? spiceLevel,
    String? budgetRange,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      allergies: allergies ?? this.allergies,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      budgetRange: budgetRange ?? this.budgetRange,
    );
  }
}
