import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.email,
    this.defaultCurrency = 'HKD',
    this.locale = 'en',
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? email;
  final String defaultCurrency;
  final String locale;
  final DateTime updatedAt;

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? defaultCurrency,
    String? locale,
    DateTime? updatedAt,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        defaultCurrency: defaultCurrency ?? this.defaultCurrency,
        locale: locale ?? this.locale,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'display_name': displayName,
        'email': email,
        'default_currency': defaultCurrency,
        'locale': locale,
        'updated_at': updatedAt.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] as String,
        displayName: map['display_name'] as String,
        email: map['email'] as String?,
        defaultCurrency: map['default_currency'] as String? ?? 'HKD',
        locale: map['locale'] as String? ?? 'en',
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  @override
  List<Object?> get props => [id, displayName, email, defaultCurrency];
}
