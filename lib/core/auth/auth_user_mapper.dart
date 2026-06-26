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
      defaultCurrency: defaultCurrency,
      updatedAt: DateTime.now(),
    );
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
