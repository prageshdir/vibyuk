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
  final String? businessGstin;
  final String creatorName;
  final String? creatorAddress;
  final String? creatorGstin;
  final String? placeOfSupply;
  final List<BookingInvoiceLineItem> lineItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  // GST breakdown — either CGST+SGST (intra-state) or IGST (inter-state)
  final double cgst;
  final double sgst;
  final double igst;
  final bool isInterState;
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
    this.businessGstin,
    required this.creatorName,
    this.creatorAddress,
    this.creatorGstin,
    this.placeOfSupply,
    required this.lineItems,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    this.cgst = 0.0,
    this.sgst = 0.0,
    this.igst = 0.0,
    this.isInterState = false,
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
  bool get hasGstBreakdown => cgst > 0 || igst > 0;

  @override
  List<Object?> get props => [
        id, bookingId, invoiceNumber, businessName, businessAddress, businessGstin,
        creatorName, creatorAddress, creatorGstin, placeOfSupply,
        lineItems, subtotal, taxRate, taxAmount, cgst, sgst, igst, isInterState,
        total, currency, status, issuedAt, dueAt, paidAt, downloadUrl, notes,
      ];
}
