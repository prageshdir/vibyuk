import 'package:equatable/equatable.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';

class DailySales extends Equatable {
  final DateTime date;
  final int tickets;
  final double revenue;

  const DailySales({
    required this.date,
    required this.tickets,
    required this.revenue,
  });

  @override
  List<Object?> get props => [date, tickets, revenue];
}

class TicketTypeSales extends Equatable {
  final String ticketTypeId;
  final String name;
  final TicketTier tier;
  final int quantity;
  final double revenue;

  const TicketTypeSales({
    required this.ticketTypeId,
    required this.name,
    required this.tier,
    required this.quantity,
    required this.revenue,
  });

  @override
  List<Object?> get props => [ticketTypeId, name, tier, quantity, revenue];
}

class EventAnalyticsEntity extends Equatable {
  final String eventId;
  final int totalCapacity;
  final int soldTickets;
  final int checkedIn;
  final double totalRevenue;
  final double refundedAmount;
  final double serviceFees;
  final List<TicketTypeSales> salesByType;
  final List<DailySales> dailySales;
  final int pendingRefunds;
  final DateTime lastUpdated;

  const EventAnalyticsEntity({
    required this.eventId,
    required this.totalCapacity,
    required this.soldTickets,
    required this.checkedIn,
    required this.totalRevenue,
    required this.refundedAmount,
    required this.serviceFees,
    required this.salesByType,
    required this.dailySales,
    required this.pendingRefunds,
    required this.lastUpdated,
  });

  double get occupancyRate =>
      totalCapacity > 0 ? soldTickets / totalCapacity : 0.0;
  double get checkInRate =>
      soldTickets > 0 ? checkedIn / soldTickets : 0.0;
  double get netRevenue => totalRevenue - refundedAmount - serviceFees;
  int get remainingCapacity => totalCapacity - soldTickets;

  @override
  List<Object?> get props => [eventId, totalCapacity, soldTickets, checkedIn,
    totalRevenue, refundedAmount, serviceFees, salesByType, dailySales,
    pendingRefunds, lastUpdated];
}
