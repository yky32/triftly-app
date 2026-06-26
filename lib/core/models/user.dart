import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.displayName,
    this.email,
    this.avatarUrl,
    this.signInProvider,
    this.defaultCurrency = 'HKD',
    this.locale = 'en',
    required this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  /// Supabase auth provider id, e.g. `google` or `email`.
  final String? signInProvider;
  final String defaultCurrency;
  final String locale;
  final DateTime updatedAt;

  bool get signedInWithGoogle => signInProvider == 'google';

  User copyWith({
    String? displayName,
    String? email,
    String? avatarUrl,
    String? signInProvider,
    String? defaultCurrency,
    String? locale,
    DateTime? updatedAt,
  }) =>
      User(
        id: id,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        signInProvider: signInProvider ?? this.signInProvider,
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

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as String,
        displayName: map['display_name'] as String,
        email: map['email'] as String?,
        defaultCurrency: map['default_currency'] as String? ?? 'HKD',
        locale: map['locale'] as String? ?? 'en',
        updatedAt: DateTime.parse(map['updated_at'] as String),
      );

  @override
  List<Object?> get props => [id, displayName, email, avatarUrl, signInProvider, defaultCurrency];
}
