import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/business/presentation/blocs/booking/booking_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/booking_card.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Upcoming', status: BookingStatus.confirmed),
    (label: 'Pending', status: BookingStatus.pending),
    (label: 'Active', status: BookingStatus.inProgress),
    (label: 'Done', status: BookingStatus.completed),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    context.read<BookingBloc>().add(const LoadBookingsEvent());
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<BookingBloc>().add(const LoadMoreBookingsEvent());
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final status = _tabs[_tabController.index].status;
    context
        .read<BookingBloc>()
        .add(FilterBookingsByStatusEvent(status: status));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) => switch (state) {
          BookingLoadingState() => const Center(child: AppLoader()),
          BookingsLoadedState(:final bookings, :final isLoadingMore) =>
            bookings.isEmpty
                ? const BusinessEmptyState.noBookings()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: bookings.length + (isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == bookings.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: AppLoader(size: 24)),
                        );
                      }
                      final booking = bookings[index];
                      return BookingCard(
                        booking: booking,
                        onTap: () =>
                            context.push('/bookings/${booking.id}'),
                      );
                    },
                  ),
          BookingErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Failed to load bookings',
              description: failure.message,
              icon: Icons.error_outline_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<BookingBloc>()
                  .add(const LoadBookingsEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
