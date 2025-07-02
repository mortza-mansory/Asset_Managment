class SubscriptionCreateModel {
  final String planType;

  SubscriptionCreateModel({required this.planType});
  Map<String, dynamic> toJson() => {'plan_type': planType};
}

class SubscriptionResponseModel {
  final int id;
  final String paymentUrl;
  final String status;

  SubscriptionResponseModel({required this.id, required this.paymentUrl, required this.status});

  factory SubscriptionResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponseModel(
      id: json['id'],
      paymentUrl: json['payment_url'],
      status: json['status'],
    );
  }
}