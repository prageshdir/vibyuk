import 'package:vibyuk/core/base/base_bloc.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_entity.dart';
import 'package:vibyuk/features/subscriptions/domain/entities/subscription_plan_features.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/cancel_subscription_use_case.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/get_subscription_use_case.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/upgrade_subscription_use_case.dart';
import 'package:vibyuk/features/subscriptions/domain/usecases/verify_subscription_payment_use_case.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc
    extends BaseBloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc({
    required GetSubscriptionUseCase getSubscription,
    required UpgradeSubscriptionUseCase upgradeSubscription,
    required VerifySubscriptionPaymentUseCase verifyPayment,
    required CancelSubscriptionUseCase cancelSubscription,
  })  : _getSubscription = getSubscription,
        _upgradeSubscription = upgradeSubscription,
        _verifyPayment = verifyPayment,
        _cancelSubscription = cancelSubscription,
        super(const SubscriptionInitial()) {
    on<LoadSubscriptionEvent>(_onLoad);
    on<InitiateUpgradeEvent>(_onInitiateUpgrade);
    on<VerifyPaymentEvent>(_onVerifyPayment);
    on<PaymentCancelledEvent>(_onPaymentCancelled);
    on<CancelSubscriptionEvent>(_onCancel);
  }

  final GetSubscriptionUseCase _getSubscription;
  final UpgradeSubscriptionUseCase _upgradeSubscription;
  final VerifySubscriptionPaymentUseCase _verifyPayment;
  final CancelSubscriptionUseCase _cancelSubscription;

  Future<void> _onLoad(
    LoadSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    final result = await _getSubscription();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionLoaded(subscription)),
    );
  }

  Future<void> _onInitiateUpgrade(
    InitiateUpgradeEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final currentPlan = state is SubscriptionLoaded
        ? (state as SubscriptionLoaded).subscription
        : null;
    emit(SubscriptionUpgrading(currentSubscription: currentPlan));

    final result = await _upgradeSubscription(
      UpgradeSubscriptionParams(plan: event.plan),
    );
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (order) => emit(SubscriptionPaymentReady(order: order)),
    );
  }

  Future<void> _onVerifyPayment(
    VerifyPaymentEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionVerifying());
    final result = await _verifyPayment(
      VerifyPaymentParams(
        paymentId: event.paymentId,
        razorpayOrderId: event.razorpayOrderId,
        signature: event.signature,
        plan: event.plan,
      ),
    );
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (subscription) => emit(SubscriptionActivated(subscription)),
    );
  }

  void _onPaymentCancelled(
    PaymentCancelledEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    // Restore loaded state or fall back to free plan
    final sub = event.previousSubscription ?? SubscriptionEntity.free();
    emit(SubscriptionLoaded(sub));
  }

  Future<void> _onCancel(
    CancelSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final currentPlan = state is SubscriptionLoaded
        ? (state as SubscriptionLoaded).subscription
        : null;
    emit(SubscriptionUpgrading(currentSubscription: currentPlan));

    final result = await _cancelSubscription();
    result.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (_) => emit(SubscriptionLoaded(SubscriptionEntity.free())),
    );
  }
}
