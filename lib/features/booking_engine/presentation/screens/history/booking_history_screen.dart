import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/booking_engine/booking_engine_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/booking_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    context
        .read<BookingEngineBloc>()
        .add(const LoadBookingsEvent(statusFilter: BookingStatus.completed));
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    final status = _tabController.index == 0
        ? BookingStatus.completed
        : BookingStatus.cancelled;
    context.read<BookingEngineBloc>().add(FilterBookingsEvent(statusFilter: status));
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
        title: const Text('Booking History',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocConsumer<BookingEngineBloc, BookingEngineState>(
        listener: (context, state) {},
        builder: (context, state) => switch (state) {
          BookingEngineLoadingState() =>
            const Center(child: AppLoader()),
          BookingEngineLoadedState(
            :final bookings,
            :final isLoadingMore,
            :final hasMore
          ) =>
            bookings.isEmpty
                ? const _EmptyHistory()
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
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: AppLoader()),
                          );
                        }
                        return BookingCard(
                          booking: bookings[i],
                          onTap: () => context.push(
                              RouteNames.bookingEngineDetail(bookings[i].id)),
                        );
                      },
                    ),
                  ),
          BookingEngineErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<BookingEngineBloc>().add(
                          LoadBookingsEvent(
                            statusFilter: _tabController.index == 0
                                ? BookingStatus.completed
                                : BookingStatus.cancelled,
                          ),
                        ),
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

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No booking history',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'Completed and cancelled bookings will appear here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
