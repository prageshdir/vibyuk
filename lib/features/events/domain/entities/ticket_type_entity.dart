import 'package:equatable/equatable.dart';

enum TicketTier { free, standard, vip, vvip }

class TicketTypeEntity extends Equatable {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final TicketTier tier;
  final double price;
  final String currency;
  final int totalQuantity;
  final int soldQuantity;
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;
  final int maxPerOrder;
  final List<String> perks;
  final bool isVisible;

  const TicketTypeEntity({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    this.tier = TicketTier.standard,
    required this.price,
    this.currency = 'INR',
    required this.totalQuantity,
    this.soldQuantity = 0,
    this.saleStartDate,
    this.saleEndDate,
    this.maxPerOrder = 10,
    this.perks = const [],
    this.isVisible = true,
  });

  int get availableQuantity => totalQuantity - soldQuantity;
  bool get isSoldOut => availableQuantity <= 0;
  bool get isFree => price == 0;

  bool get isSaleActive {
    final now = DateTime.now();
    if (saleStartDate != null && now.isBefore(saleStartDate!)) return false;
    if (saleEndDate != null && now.isAfter(saleEndDate!)) return false;
    return true;
  }

  TicketTypeEntity copyWith({
    String? id, String? eventId, String? name, String? description,
    TicketTier? tier, double? price, String? currency,
    int? totalQuantity, int? soldQuantity,
    DateTime? saleStartDate, DateTime? saleEndDate,
    int? maxPerOrder, List<String>? perks, bool? isVisible,
  }) => TicketTypeEntity(
    id: id ?? this.id, eventId: eventId ?? this.eventId,
    name: name ?? this.name, description: description ?? this.description,
    tier: tier ?? this.tier, price: price ?? this.price,
    currency: currency ?? this.currency, totalQuantity: totalQuantity ?? this.totalQuantity,
    soldQuantity: soldQuantity ?? this.soldQuantity,
    saleStartDate: saleStartDate ?? this.saleStartDate,
    saleEndDate: saleEndDate ?? this.saleEndDate,
    maxPerOrder: maxPerOrder ?? this.maxPerOrder,
    perks: perks ?? this.perks, isVisible: isVisible ?? this.isVisible,
  );

  @override
  List<Object?> get props => [id, eventId, name, description, tier, price,
    currency, totalQuantity, soldQuantity, saleStartDate, saleEndDate,
    maxPerOrder, perks, isVisible];
}
