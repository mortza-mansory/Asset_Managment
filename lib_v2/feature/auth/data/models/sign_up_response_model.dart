
import 'package:assetsrfid/feature/auth/domain/entity/temp_token_entity.dart';

class SignUpResponseModel extends TempTokenEntity {
  const SignUpResponseModel({required super.tempToken});

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(tempToken: json['access_token']);
  }

  Map<String, dynamic> toJson() => {'access_token': tempToken};
}