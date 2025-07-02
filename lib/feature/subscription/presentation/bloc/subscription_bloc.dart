import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assetsrfid/feature/subscription/data/datasource/subscription_remote_datasource.dart';
import 'package:assetsrfid/feature/subscription/data/models/subscription_model.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRemoteDataSource dataSource;

  SubscriptionBloc({required this.dataSource}) : super(SubscriptionInitial()) {
    on<CheckCurrentUserSubscription>(_onCheckStatus);
    on<CreateSubscription>(_onCreateSubscription);
    on<ConfirmPayment>(_onConfirmPayment);
  }

  void _onCreateSubscription(CreateSubscription event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final model = SubscriptionCreateModel(planType: event.planType);
      final response = await dataSource.createSubscription(model);
      print("===================");
       print(response.paymentUrl);
      emit(SubscriptionLinkCreated(paymentUrl: response.paymentUrl, subscriptionId: response.id));
    } catch (e) {
      emit(SubscriptionFailure(message: e.toString()));
    }
  }

  void _onCheckStatus(CheckCurrentUserSubscription event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      final isActive = await dataSource.hasActiveSubscription();
      emit(UserSubscriptionStatus(isActive: isActive));
    } catch (e) {
      emit(SubscriptionFailure(message: e.toString()));
    }
  }

  void _onConfirmPayment(ConfirmPayment event, Emitter<SubscriptionState> emit) async {
    emit(SubscriptionLoading());
    try {
      // در اینجا می‌توانستیم وضعیت را از سرور چک کنیم
      // اما برای شبیه‌سازی، فرض می‌کنیم موفقیت‌آمیز است
      await Future.delayed(const Duration(seconds: 2));
      emit(SubscriptionActivated());
    } catch(e) {
      emit(SubscriptionFailure(message: e.toString()));
    }
  }
}