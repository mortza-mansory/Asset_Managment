class TokenResponseModel {
  final String accessToken;
  final String refreshToken;

  const TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) {
    return TokenResponseModel(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
  };
}