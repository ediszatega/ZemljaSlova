import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

enum AuthResult {
  @JsonValue(0)
  success,
  @JsonValue(1)
  userNotFound,
  @JsonValue(2)
  invalidPassword,
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'result', fromJson: _authResultFromJson, toJson: _authResultToJson)
  AuthResult? result;
  @JsonKey(name: 'token')
  String? token;
  @JsonKey(name: 'userId')
  int? userId;
  @JsonKey(name: 'role')
  String? role;

  LoginResponse(this.result, this.token, this.userId, this.role);

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  bool get isSuccess => result == AuthResult.success;

  static AuthResult? _authResultFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return AuthResult.values[value];
    }
    return null;
  }

  static int? _authResultToJson(AuthResult? value) {
    return value?.index;
  }
} 