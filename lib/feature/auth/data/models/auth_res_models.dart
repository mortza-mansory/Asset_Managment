class SignUpResponseModel {
  final int id;
  final String username;
  final String tempToken;

  SignUpResponseModel({required this.id, required this.username, required this.tempToken});

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      id: json['id'],
      username: json['username'],
      tempToken: json['temp_token'],
    );
  }
}

class LoginResponseModel {
  final int userId;
  final String tempToken;

  LoginResponseModel({required this.userId, required this.tempToken});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      userId: json['user_id'],
      tempToken: json['temp_token'],
    );
  }
}

class ResetCodeResponseModel {
  final int userId;
  final String code;

  ResetCodeResponseModel({required this.userId, required this.code});

  factory ResetCodeResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetCodeResponseModel(
      userId: json['user_id'],
      code: json['code'],
    );
  }
}

class TokenResponseModel {
  final String accessToken;

  TokenResponseModel({required this.accessToken});

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenResponseModel(
      accessToken: json['access_token']?.toString() ?? '',
    );
  }
}