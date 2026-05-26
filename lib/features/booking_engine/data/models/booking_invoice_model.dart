import 'package:vibyuk/features/booking_engine/domain/entities/booking_invoice_entity.dart';

class BookingInvoiceLineItemModel {
  const BookingInvoiceLineItemModel({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  factory BookingInvoiceLineItemModel.fromJson(Map<String, dynamic> j) =>
      BookingInvoiceLineItemModel(
        description: j['description'] as String,
        quantity: j['quantity'] as int? ?? 1,
        unitPrice: (j['unit_price'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
      );

  BookingInvoiceLineItem toEntity() => BookingInvoiceLineItem(
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        total: total,
      );
}

class BookingInvoiceModel {
  const BookingInvoiceModel({
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
  final List<BookingInvoiceLineItemModel> lineItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
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

  factory BookingInvoiceModel.fromJson(Map<String, dynamic> j) =>
      BookingInvoiceModel(
        id: j['id'] as String,
        bookingId: j['booking_id'] as String,
        invoiceNumber: j['invoice_number'] as String,
        businessName: j['business_name'] as String,
        businessAddress: j['business_address'] as String?,
        businessGstin: j['business_gstin'] as String?,
        creatorName: j['creator_name'] as String,
        creatorAddress: j['creator_address'] as String?,
        creatorGstin: j['creator_gstin'] as String?,
        placeOfSupply: j['place_of_supply'] as String?,
        lineItems: (j['line_items'] as List<dynamic>? ?? [])
            .map((e) =>
                BookingInvoiceLineItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (j['subtotal'] as num).toDouble(),
        taxRate: (j['tax_rate'] as num? ?? 0).toDouble(),
        taxAmount: (j['tax_amount'] as num? ?? 0).toDouble(),
        cgst: (j['cgst'] as num? ?? 0).toDouble(),
        sgst: (j['sgst'] as num? ?? 0).toDouble(),
        igst: (j['igst'] as num? ?? 0).toDouble(),
        isInterState: j['is_inter_state'] as bool? ?? false,
        total: (j['total'] as num).toDouble(),
        currency: j['currency'] as String,
        status: InvoiceStatus.values.firstWhere(
            (s) => s.name == j['status'],
            orElse: () => InvoiceStatus.issued),
        issuedAt: DateTime.parse(j['issued_at'] as String),
        dueAt: j['due_at'] != null
            ? DateTime.parse(j['due_at'] as String)
            : null,
        paidAt: j['paid_at'] != null
            ? DateTime.parse(j['paid_at'] as String)
            : null,
        downloadUrl: j['download_url'] as String?,
        notes: j['notes'] as String?,
      );

  BookingInvoiceEntity toEntity() => BookingInvoiceEntity(
        id: id,
        bookingId: bookingId,
        invoiceNumber: invoiceNumber,
        businessName: businessName,
        businessAddress: businessAddress,
        businessGstin: businessGstin,
        creatorName: creatorName,
        creatorAddress: creatorAddress,
        creatorGstin: creatorGstin,
        placeOfSupply: placeOfSupply,
        lineItems: lineItems.map((e) => e.toEntity()).toList(),
        subtotal: subtotal,
        taxRate: taxRate,
        taxAmount: taxAmount,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
        isInterState: isInterState,
        total: total,
        currency: currency,
        status: status,
        issuedAt: issuedAt,
        dueAt: dueAt,
        paidAt: paidAt,
        downloadUrl: downloadUrl,
        notes: notes,
      );
}
