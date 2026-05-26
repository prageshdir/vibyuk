import 'package:equatable/equatable.dart';

class GstDetailsEntity extends Equatable {
  const GstDetailsEntity({
    required this.gstin,
    required this.legalName,
    required this.address,
    required this.state,
    required this.stateCode,
  });

  final String gstin;
  final String legalName;
  final String address;
  final String state;
  final String stateCode;

  @override
  List<Object?> get props => [gstin, legalName, address, state, stateCode];
}

class InvoiceLineItemEntity extends Equatable {
  const InvoiceLineItemEntity({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.hsnCode,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.igstPercent,
  });

  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String hsnCode;
  final double cgstPercent;
  final double sgstPercent;
  final double igstPercent;

  double get cgstAmount => totalPrice * cgstPercent / 100;
  double get sgstAmount => totalPrice * sgstPercent / 100;
  double get igstAmount => totalPrice * igstPercent / 100;
  double get totalTax => cgstAmount + sgstAmount + igstAmount;
  double get grandTotal => totalPrice + totalTax;

  @override
  List<Object?> get props => [
        description, quantity, unitPrice, totalPrice,
        hsnCode, cgstPercent, sgstPercent, igstPercent,
      ];
}

class InvoiceEntity extends Equatable {
  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.bookingId,
    required this.paymentId,
    required this.issuerGst,
    required this.recipientGst,
    required this.lineItems,
    required this.subtotal,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalTax,
    required this.grandTotal,
    this.currency = 'INR',
    required this.issuedAt,
    this.pdfUrl,
    required this.isInterState,
  });

  final String id;
  final String invoiceNumber;
  final String bookingId;
  final String paymentId;
  final GstDetailsEntity issuerGst;
  final GstDetailsEntity recipientGst;
  final List<InvoiceLineItemEntity> lineItems;
  final double subtotal;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalTax;
  final double grandTotal;
  final String currency;
  final DateTime issuedAt;
  final String? pdfUrl;
  final bool isInterState;

  String get grandTotalDisplay => '₹${grandTotal.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id, invoiceNumber, bookingId, paymentId,
        issuerGst, recipientGst, lineItems,
        subtotal, totalCgst, totalSgst, totalIgst, totalTax, grandTotal,
        currency, issuedAt, pdfUrl, isInterState,
      ];
}
