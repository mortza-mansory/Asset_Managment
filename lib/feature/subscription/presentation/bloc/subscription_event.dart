abstract class SubscriptionEvent {}

class CheckCurrentUserSubscription extends SubscriptionEvent {}

class CreateSubscription extends SubscriptionEvent {
  final String planType;
  CreateSubscription({required this.planType});
}

class ConfirmPayment extends SubscriptionEvent {
  final int subscriptionId;
  ConfirmPayment({required this.subscriptionId});
}