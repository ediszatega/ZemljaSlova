import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'result')
  int? result;
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

  bool get isSuccess => result == 0;
}