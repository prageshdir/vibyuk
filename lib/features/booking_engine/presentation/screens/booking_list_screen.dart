import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_engine/booking_engine_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/booking_card.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({super.key});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Active', status: BookingStatus.active),
    (label: 'Pending', status: BookingStatus.pending),
    (label: 'Completed', status: BookingStatus.completed),
    (label: 'Cancelled', status: BookingStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<BookingEngineBloc>().add(const LoadBookingsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    context.read<BookingEngineBloc>().add(
          FilterBookingsEvent(
              statusFilter: _tabs[_tabController.index].status),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<BookingEngineBloc>().add(const LoadMoreBookingsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: BlocBuilder<BookingEngineBloc, BookingEngineState>(
        builder: (context, state) => switch (state) {
          BookingEngineLoadingState() =>
            const Center(child: AppLoader()),
          BookingEngineLoadedState(
            :final bookings,
            :final isLoadingMore
          ) =>
            bookings.isEmpty
                ? const _EmptyBookings()
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<BookingEngineBloc>()
                        .add(const RefreshBookingsEvent()),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == bookings.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppLoader(size: 24)),
                          );
                        }
                        final booking = bookings[i];
                        return BookingCard(
                          booking: booking,
                          onTap: () => context.push(
                              RouteNames.bookingEngineDetail(booking.id)),
                        );
                      },
                    ),
                  ),
          BookingEngineErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<BookingEngineBloc>()
                        .add(const RefreshBookingsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text('No bookings yet',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Your bookings will appear here once confirmed.',
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
