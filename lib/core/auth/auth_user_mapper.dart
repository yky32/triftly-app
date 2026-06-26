import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../models/user.dart';

/// Maps Supabase Auth users (Google OAuth, email OTP) to app [User] models.
abstract final class AuthUserMapper {
  static User fromAuthUser(
    supabase.User authUser, {
    required String defaultCurrency,
  }) {
    final metadata = authUser.userMetadata;
    return User(
      id: authUser.id,
      displayName: displayNameFromMetadata(metadata, authUser.email),
      email: authUser.email,
      avatarUrl: avatarUrlFromMetadata(metadata),
      signInProvider: signInProviderFromAuthUser(authUser),
      defaultCurrency: defaultCurrency,
      updatedAt: DateTime.now(),
    );
  }

  static String? signInProviderFromAuthUser(supabase.User authUser) {
    final identities = authUser.identities;
    if (identities != null) {
      for (final identity in identities) {
        if (identity.provider == 'google') return 'google';
      }
      if (identities.isNotEmpty) return identities.first.provider;
    }
    final fromApp = _nonEmpty(authUser.appMetadata['provider'] as String?);
    return fromApp;
  }

  static String displayNameFromMetadata(
    Map<String, dynamic>? metadata,
    String? email,
  ) {
    final fromMeta = _nonEmpty(metadata?['full_name'] as String?) ??
        _nonEmpty(metadata?['name'] as String?) ??
        _nonEmpty(metadata?['display_name'] as String?);
    if (fromMeta != null) return fromMeta;
    final local = email?.split('@').first;
    if (local != null && local.isNotEmpty) return local;
    return 'Traveler';
  }

  static String? avatarUrlFromMetadata(Map<String, dynamic>? metadata) {
    return _nonEmpty(metadata?['avatar_url'] as String?) ??
        _nonEmpty(metadata?['picture'] as String?);
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
