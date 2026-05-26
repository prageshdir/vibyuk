import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, issued, paid, overdue, voided }

class BookingInvoiceLineItem extends Equatable {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  const BookingInvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [description, quantity, unitPrice, total];
}

class BookingInvoiceEntity extends Equatable {
  final String id;
  final String bookingId;
  final String invoiceNumber;
  final String businessName;
  final String? businessAddress;
  final String creatorName;
  final String? creatorAddress;
  final List<BookingInvoiceLineItem> lineItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String currency;
  final InvoiceStatus status;
  final DateTime issuedAt;
  final DateTime? dueAt;
  final DateTime? paidAt;
  final String? downloadUrl;
  final String? notes;

  const BookingInvoiceEntity({
    required this.id,
    required this.bookingId,
    required this.invoiceNumber,
    required this.businessName,
    this.businessAddress,
    required this.creatorName,
    this.creatorAddress,
    required this.lineItems,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.currency,
    required this.status,
    required this.issuedAt,
    this.dueAt,
    this.paidAt,
    this.downloadUrl,
    this.notes,
  });

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue =>
      status == InvoiceStatus.issued &&
      dueAt != null &&
      DateTime.now().isAfter(dueAt!);

  @override
  List<Object?> get props => [
        id, bookingId, invoiceNumber, businessName, businessAddress,
        creatorName, creatorAddress, lineItems, subtotal, taxRate, taxAmount,
        total, currency, status, issuedAt, dueAt, paidAt, downloadUrl, notes,
      ];
}
