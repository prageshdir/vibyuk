import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

enum EventStatus { draft, published, cancelled, ended, soldOut }
enum EventCategory {
  music, sports, arts, food, tech, networking, education, conference, other
}

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final String? organizerAvatarUrl;
  final String? coverImageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final String venueName;
  final String? venueAddress;
  final double? latitude;
  final double? longitude;
  final bool isOnline;
  final String? streamUrl;
  final EventStatus status;
  final EventCategory category;
  final List<TicketTypeEntity> ticketTypes;
  final int totalCapacity;
  final int soldTickets;
  final String currency;
  final List<String> tags;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    this.organizerAvatarUrl,
    this.coverImageUrl,
    required this.startDate,
    required this.endDate,
    required this.venueName,
    this.venueAddress,
    this.latitude,
    this.longitude,
    this.isOnline = false,
    this.streamUrl,
    this.status = EventStatus.draft,
    this.category = EventCategory.other,
    this.ticketTypes = const [],
    this.totalCapacity = 0,
    this.soldTickets = 0,
    this.currency = 'USD',
    this.tags = const [],
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get occupancyRate =>
      totalCapacity > 0 ? soldTickets / totalCapacity : 0.0;
  int get remainingCapacity => totalCapacity - soldTickets;
  bool get isSoldOut => remainingCapacity <= 0;
  bool get isUpcoming => DateTime.now().isBefore(startDate);
  bool get isOngoing =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);
  bool get hasEnded => DateTime.now().isAfter(endDate);
  double? get minTicketPrice {
    final visible = ticketTypes.where((t) => t.isVisible && !t.isSoldOut);
    if (visible.isEmpty) return null;
    return visible.map((t) => t.price).reduce((a, b) => a < b ? a : b);
  }

  EventEntity copyWith({
    String? id, String? title, String? description,
    String? organizerId, String? organizerName, String? organizerAvatarUrl,
    String? coverImageUrl, DateTime? startDate, DateTime? endDate,
    String? venueName, String? venueAddress, double? latitude, double? longitude,
    bool? isOnline, String? streamUrl, EventStatus? status,
    EventCategory? category, List<TicketTypeEntity>? ticketTypes,
    int? totalCapacity, int? soldTickets, String? currency,
    List<String>? tags, bool? isFeatured, DateTime? createdAt, DateTime? updatedAt,
  }) => EventEntity(
    id: id ?? this.id, title: title ?? this.title,
    description: description ?? this.description,
    organizerId: organizerId ?? this.organizerId,
    organizerName: organizerName ?? this.organizerName,
    organizerAvatarUrl: organizerAvatarUrl ?? this.organizerAvatarUrl,
    coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
    venueName: venueName ?? this.venueName, venueAddress: venueAddress ?? this.venueAddress,
    latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude,
    isOnline: isOnline ?? this.isOnline, streamUrl: streamUrl ?? this.streamUrl,
    status: status ?? this.status, category: category ?? this.category,
    ticketTypes: ticketTypes ?? this.ticketTypes,
    totalCapacity: totalCapacity ?? this.totalCapacity,
    soldTickets: soldTickets ?? this.soldTickets, currency: currency ?? this.currency,
    tags: tags ?? this.tags, isFeatured: isFeatured ?? this.isFeatured,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [id, title, description, organizerId, organizerName,
    organizerAvatarUrl, coverImageUrl, startDate, endDate, venueName, venueAddress,
    latitude, longitude, isOnline, streamUrl, status, category, ticketTypes,
    totalCapacity, soldTickets, currency, tags, isFeatured, createdAt, updatedAt];
}
