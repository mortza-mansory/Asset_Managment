import 'dart:convert';

class SignUpRequestModel {
  final String username;
  final String password;
  final String? phoneNum;
  final String? email;

  SignUpRequestModel({
    required this.username,
    required this.password,
    this.phoneNum,
    this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'phone_num': phoneNum,
      'email': email,
    };
  }
}

class VerifyOtpRequestModel {
  final int userId;
  final String otp;
  final String tempToken;

  VerifyOtpRequestModel({
    required this.userId,
    required this.otp,
    required this.tempToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'otp': otp,
      'temp_token': tempToken,
    };
  }
}