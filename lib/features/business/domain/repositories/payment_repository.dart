import 'package:dartz/dartz.dart';
import 'package:vibyuk/core/error/failures.dart';
import 'package:vibyuk/features/business/domain/entities/escrow_entity.dart';
import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';
import 'package:vibyuk/features/business/domain/entities/paginated_result.dart';
import 'package:vibyuk/features/business/domain/entities/payment_entity.dart';
import 'package:vibyuk/features/business/domain/entities/payment_order_entity.dart';
import 'package:vibyuk/features/business/domain/entities/transaction_entity.dart';

abstract interface class PaymentRepository {
  // ── Payment List & Detail ─────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResult<PaymentEntity>>> getPayments({
    required int page,
    int pageSize = 20,
    PaymentStatus? status,
  });

  Future<Either<Failure, PaymentEntity>> getPaymentDetail(String paymentId);

  // ── Payment Initiation (Razorpay / Cashfree) ──────────────────────────────
  Future<Either<Failure, PaymentOrderEntity>> initiatePayment({
    required String bookingId,
    required double amount,
    required PaymentGateway gateway,
  });

  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String paymentId,
    required String gatewayOrderId,
    required String gatewayPaymentId,
    required String signature,
    required PaymentGateway gateway,
  });

  // ── Escrow ────────────────────────────────────────────────────────────────
  Future<Either<Failure, EscrowEntity>> getEscrowDetails(String bookingId);

  Future<Either<Failure, EscrowEntity>> releaseEscrow({
    required String escrowId,
    String? milestoneId,
  });

  Future<Either<Failure, EscrowEntity>> requestRefund({
    required String escrowId,
    required String reason,
  });

  // ── Transaction History ───────────────────────────────────────────────────
  Future<Either<Failure, PaginatedResult<TransactionEntity>>> getTransactions({
    required int page,
    int pageSize = 20,
    TransactionType? type,
  });

  // ── GST Invoice ───────────────────────────────────────────────────────────
  Future<Either<Failure, InvoiceEntity>> getInvoice(String bookingId);
  Future<Either<Failure, String>> getInvoicePdfUrl(String invoiceId);
}
