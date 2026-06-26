part of 'session_bloc.dart';

class SessionState extends Equatable {
  const SessionState({
    this.user,
    required this.fallbackCurrency,
  });

  final User? user;
  final String fallbackCurrency;

  User? get currentUser => user;

  bool get isSignedIn => user != null;

  bool get isCloudSignedIn => CloudTripSync.isCloudUserId(user?.id);

  String get defaultCurrency => user?.defaultCurrency ?? fallbackCurrency;

  factory SessionState.initial(User? user, String fallbackCurrency) =>
      SessionState(user: user, fallbackCurrency: fallbackCurrency);

  SessionState copyWith({
    User? user,
    String? fallbackCurrency,
  }) =>
      SessionState(
        user: user ?? this.user,
        fallbackCurrency: fallbackCurrency ?? this.fallbackCurrency,
      );

  @override
  List<Object?> get props => [user, fallbackCurrency];
}
