import 'package:equatable/equatable.dart';

class CommonResponse extends Equatable {
  final String code;
  final String message;
  final String httpStatus;

  const CommonResponse({
    required this.code,
    required this.message,
    required this.httpStatus,
  });

  factory CommonResponse.fromMap(Map<String, dynamic> data) {
    return CommonResponse(
      code: data['code'] as String,
      message: data['message'] as String,
      httpStatus: data['httpStatus'] as String,
    );
  }

  Map<String, dynamic> toMap() => {
        'code': code,
        'message': message,
        'httpStatus': httpStatus,
      };

  @override
  bool get stringify => true;

  @override
  List<Object?> get props => [
        code,
        message,
        httpStatus,
      ];
}
