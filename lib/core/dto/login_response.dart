import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String expiresIn;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> data) => LoginResponse(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String,
        tokenType: data['tokenType'] as String,
        expiresIn: data['expiresIn'] as String,
      );

  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'expiresIn': expiresIn,
      };

  LoginResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    String? expiresIn,
    bool? kycRequired,
  }) {
    return LoginResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      accessToken,
      refreshToken,
      tokenType,
      expiresIn,
    ];
  }
}
