import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}
class SubscriptionLoading extends SubscriptionState {}

class UserSubscriptionStatus extends SubscriptionState {
  final bool isActive;
  const UserSubscriptionStatus({required this.isActive});
  @override
  List<Object> get props => [isActive];
}

class SubscriptionLinkCreated extends SubscriptionState {
  final String paymentUrl;
  final int subscriptionId;
  const SubscriptionLinkCreated({required this.paymentUrl, required this.subscriptionId});
  @override
  List<Object> get props => [paymentUrl, subscriptionId];
}

class SubscriptionActivated extends SubscriptionState {}

class SubscriptionFailure extends SubscriptionState {
  final String message;
  const SubscriptionFailure({required this.message});
  @override
  List<Object> get props => [message];
}