import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

class TicketTypeFormData extends Equatable {
  final String? id;
  final String name;
  final TicketTier tier;
  final double price;
  final int quantity;
  final int maxPerOrder;
  final List<String> perks;
  final DateTime? saleEndDate;

  const TicketTypeFormData({
    this.id,
    required this.name,
    this.tier = TicketTier.standard,
    required this.price,
    required this.quantity,
    this.maxPerOrder = 10,
    this.perks = const [],
    this.saleEndDate,
  });

  bool get isFree => price == 0;

  TicketTypeFormData copyWith({
    String? id, String? name, TicketTier? tier, double? price,
    int? quantity, int? maxPerOrder, List<String>? perks, DateTime? saleEndDate,
  }) => TicketTypeFormData(
    id: id ?? this.id, name: name ?? this.name, tier: tier ?? this.tier,
    price: price ?? this.price, quantity: quantity ?? this.quantity,
    maxPerOrder: maxPerOrder ?? this.maxPerOrder,
    perks: perks ?? this.perks, saleEndDate: saleEndDate ?? this.saleEndDate,
  );

  @override
  List<Object?> get props =>
      [id, name, tier, price, quantity, maxPerOrder, perks, saleEndDate];
}

class EventFormData extends Equatable {
  final String title;
  final String description;
  final EventCategory category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String venueName;
  final String venueAddress;
  final bool isOnline;
  final String streamUrl;
  final String? coverImagePath;
  final String? existingCoverUrl;
  final List<TicketTypeFormData> ticketTypes;
  final int currentStep;
  final Map<String, String> fieldErrors;

  const EventFormData({
    this.title = '',
    this.description = '',
    this.category = EventCategory.other,
    this.startDate,
    this.endDate,
    this.venueName = '',
    this.venueAddress = '',
    this.isOnline = false,
    this.streamUrl = '',
    this.coverImagePath,
    this.existingCoverUrl,
    this.ticketTypes = const [],
    this.currentStep = 0,
    this.fieldErrors = const {},
  });

  bool get isStep0Valid =>
      title.trim().isNotEmpty && description.trim().isNotEmpty;
  bool get isStep1Valid =>
      startDate != null &&
      endDate != null &&
      endDate!.isAfter(startDate!) &&
      (isOnline || venueName.trim().isNotEmpty);
  bool get isStep2Valid => ticketTypes.isNotEmpty;
  bool get canSubmit => isStep0Valid && isStep1Valid && isStep2Valid;

  EventFormData copyWith({
    String? title, String? description, EventCategory? category,
    DateTime? startDate, DateTime? endDate, String? venueName,
    String? venueAddress, bool? isOnline, String? streamUrl,
    String? coverImagePath, String? existingCoverUrl,
    List<TicketTypeFormData>? ticketTypes, int? currentStep,
    Map<String, String>? fieldErrors,
  }) => EventFormData(
    title: title ?? this.title, description: description ?? this.description,
    category: category ?? this.category, startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate, venueName: venueName ?? this.venueName,
    venueAddress: venueAddress ?? this.venueAddress,
    isOnline: isOnline ?? this.isOnline, streamUrl: streamUrl ?? this.streamUrl,
    coverImagePath: coverImagePath ?? this.coverImagePath,
    existingCoverUrl: existingCoverUrl ?? this.existingCoverUrl,
    ticketTypes: ticketTypes ?? this.ticketTypes,
    currentStep: currentStep ?? this.currentStep,
    fieldErrors: fieldErrors ?? this.fieldErrors,
  );

  @override
  List<Object?> get props => [title, description, category, startDate, endDate,
    venueName, venueAddress, isOnline, streamUrl, coverImagePath,
    existingCoverUrl, ticketTypes, currentStep, fieldErrors];
}
