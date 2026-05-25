import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, completed, failed, refunded }
enum PaymentType { booking, subscription, addon }

extension PaymentStatusX on PaymentStatus {
  String get label => switch (this) {
        PaymentStatus.pending => 'Pending',
        PaymentStatus.completed => 'Completed',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.refunded => 'Refunded',
      };
}

extension PaymentTypeX on PaymentType {
  String get label => switch (this) {
        PaymentType.booking => 'Booking',
        PaymentType.subscription => 'Subscription',
        PaymentType.addon => 'Add-on',
      };
}

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.amount,
    this.currency = 'GBP',
    required this.status,
    required this.type,
    required this.description,
    this.bookingId,
    this.campaignId,
    required this.createdAt,
  });

  final String id;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentType type;
  final String description;
  final String? bookingId;
  final String? campaignId;
  final DateTime createdAt;

  String get amountDisplay => '£${amount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id, amount, currency, status, type, description,
        bookingId, campaignId, createdAt,
      ];
}
