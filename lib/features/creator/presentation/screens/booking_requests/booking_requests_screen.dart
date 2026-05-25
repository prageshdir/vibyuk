import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/booking_requests/booking_requests_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/booking_request_card.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_empty_state.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final TabController _tabController;

  static const _tabs = [
    (label: 'All', status: null),
    (label: 'Pending', status: BookingRequestStatus.pending),
    (label: 'Accepted', status: BookingRequestStatus.accepted),
    (label: 'Declined', status: BookingRequestStatus.declined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<BookingRequestsBloc>().add(const LoadBookingRequestsEvent());
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
    context.read<BookingRequestsBloc>().add(
          FilterBookingRequestsEvent(
              statusFilter: _tabs[_tabController.index].status),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context
          .read<BookingRequestsBloc>()
          .add(const LoadMoreBookingRequestsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests',
            style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t.label)).toList(),
        ),
      ),
      body: BlocBuilder<BookingRequestsBloc, BookingRequestsState>(
        builder: (context, state) => switch (state) {
          BookingRequestsLoadingState() => const Center(child: AppLoader()),
          BookingRequestsLoadedState(
            :final requests,
            :final isLoadingMore
          ) =>
            requests.isEmpty
                ? const CreatorEmptyState.noBookingRequests()
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<BookingRequestsBloc>()
                        .add(const LoadBookingRequestsEvent()),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          requests.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == requests.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: AppLoader(size: 24)),
                          );
                        }
                        final req = requests[i];
                        return BookingRequestCard(
                          request: req,
                          onTap: () {
                            context.read<BookingRequestsBloc>().add(
                                  LoadBookingRequestDetailEvent(
                                      requestId: req.id),
                                );
                            context.push(
                              RouteNames.creatorBookingRequestDetail(req.id),
                            );
                          },
                          onAccept: req.canRespond
                              ? () => context
                                  .read<BookingRequestsBloc>()
                                  .add(RespondToBookingRequestEvent(
                                    requestId: req.id,
                                    accept: true,
                                  ))
                              : null,
                          onDecline: req.canRespond
                              ? () => _showDeclineDialog(context, req)
                              : null,
                        );
                      },
                    ),
                  ),
          BookingRequestsErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<BookingRequestsBloc>()
                        .add(const LoadBookingRequestsEvent()),
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

  void _showDeclineDialog(BuildContext context, BookingRequestEntity req) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Decline Request'),
        content: Text(
            'Decline booking request from ${req.businessName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingRequestsBloc>().add(
                    RespondToBookingRequestEvent(
                      requestId: req.id,
                      accept: false,
                    ),
                  );
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}
