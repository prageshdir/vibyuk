import 'package:vibyuk/features/business/domain/entities/invoice_entity.dart';

class GstDetailsModel {
  const GstDetailsModel({
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

  factory GstDetailsModel.fromJson(Map<String, dynamic> j) => GstDetailsModel(
        gstin: j['gstin'] as String,
        legalName: j['legal_name'] as String,
        address: j['address'] as String,
        state: j['state'] as String,
        stateCode: j['state_code'] as String,
      );

  GstDetailsEntity toEntity() => GstDetailsEntity(
        gstin: gstin,
        legalName: legalName,
        address: address,
        state: state,
        stateCode: stateCode,
      );
}

class InvoiceLineItemModel {
  const InvoiceLineItemModel({
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

  factory InvoiceLineItemModel.fromJson(Map<String, dynamic> j) =>
      InvoiceLineItemModel(
        description: j['description'] as String,
        quantity: j['quantity'] as int? ?? 1,
        unitPrice: (j['unit_price'] as num).toDouble(),
        totalPrice: (j['total_price'] as num).toDouble(),
        hsnCode: j['hsn_code'] as String? ?? '',
        cgstPercent: (j['cgst_percent'] as num? ?? 0).toDouble(),
        sgstPercent: (j['sgst_percent'] as num? ?? 0).toDouble(),
        igstPercent: (j['igst_percent'] as num? ?? 0).toDouble(),
      );

  InvoiceLineItemEntity toEntity() => InvoiceLineItemEntity(
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        hsnCode: hsnCode,
        cgstPercent: cgstPercent,
        sgstPercent: sgstPercent,
        igstPercent: igstPercent,
      );
}

class InvoiceModel {
  const InvoiceModel({
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
    required this.currency,
    required this.issuedAt,
    this.pdfUrl,
    required this.isInterState,
  });

  final String id;
  final String invoiceNumber;
  final String bookingId;
  final String paymentId;
  final GstDetailsModel issuerGst;
  final GstDetailsModel recipientGst;
  final List<InvoiceLineItemModel> lineItems;
  final double subtotal;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalTax;
  final double grandTotal;
  final String currency;
  final String issuedAt;
  final String? pdfUrl;
  final bool isInterState;

  factory InvoiceModel.fromJson(Map<String, dynamic> j) => InvoiceModel(
        id: j['id'] as String,
        invoiceNumber: j['invoice_number'] as String,
        bookingId: j['booking_id'] as String,
        paymentId: j['payment_id'] as String,
        issuerGst:
            GstDetailsModel.fromJson(j['issuer_gst'] as Map<String, dynamic>),
        recipientGst: GstDetailsModel.fromJson(
            j['recipient_gst'] as Map<String, dynamic>),
        lineItems: (j['line_items'] as List? ?? [])
            .map((e) =>
                InvoiceLineItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        subtotal: (j['subtotal'] as num).toDouble(),
        totalCgst: (j['total_cgst'] as num? ?? 0).toDouble(),
        totalSgst: (j['total_sgst'] as num? ?? 0).toDouble(),
        totalIgst: (j['total_igst'] as num? ?? 0).toDouble(),
        totalTax: (j['total_tax'] as num? ?? 0).toDouble(),
        grandTotal: (j['grand_total'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'INR',
        issuedAt: j['issued_at'] as String,
        pdfUrl: j['pdf_url'] as String?,
        isInterState: j['is_inter_state'] as bool? ?? false,
      );

  InvoiceEntity toEntity() => InvoiceEntity(
        id: id,
        invoiceNumber: invoiceNumber,
        bookingId: bookingId,
        paymentId: paymentId,
        issuerGst: issuerGst.toEntity(),
        recipientGst: recipientGst.toEntity(),
        lineItems: lineItems.map((e) => e.toEntity()).toList(),
        subtotal: subtotal,
        totalCgst: totalCgst,
        totalSgst: totalSgst,
        totalIgst: totalIgst,
        totalTax: totalTax,
        grandTotal: grandTotal,
        currency: currency,
        issuedAt: DateTime.parse(issuedAt),
        pdfUrl: pdfUrl,
        isInterState: isInterState,
      );
}
