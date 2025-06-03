
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';

class LoginResponseModel extends TempTokenEntity {
  const LoginResponseModel({required super.tempToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(tempToken: json['access_token']);
  }

  Map<String, dynamic> toJson() => {'access_token': tempToken};
}