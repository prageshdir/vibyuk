import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/core/pagination/pagination_event.dart';
import 'package:vibyuk/core/pagination/pagination_state.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/my_tickets/my_tickets_bloc.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  static const _tabs = [
    (null, 'All'),
    (TicketStatus.active, 'Active'),
    (TicketStatus.used, 'Used'),
    (TicketStatus.cancelled, 'Cancelled'),
    (TicketStatus.refunded, 'Refunded'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyTicketsBloc>().add(const FetchFirstPage<TicketEntity>());
    });
    _scrollController.addListener(_onScroll);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final (status, _) = _tabs[_tabController.index];
    context
        .read<MyTicketsBloc>()
        .add(TicketStatusFilterChanged(status: status));
  }

  void _onScroll() {
    final state = context.read<MyTicketsBloc>().state;
    if (state is PaginationLoaded<TicketEntity> &&
        !state.isFetchingMore &&
        !state.hasReachedEnd) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll - 200) {
        context
            .read<MyTicketsBloc>()
            .add(const FetchNextPage<TicketEntity>());
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.map((t) => Tab(text: t.$2)).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<MyTicketsBloc>()
              .add(const RefreshPage<TicketEntity>());
        },
        child: BlocBuilder<MyTicketsBloc, PaginationState<TicketEntity>>(
          builder: (context, state) {
            if (state is PaginationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is PaginationEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No tickets found'),
                  ],
                ),
              );
            }
            if (state is PaginationError && !state.hasPreviousData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(state.failure.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context
                          .read<MyTicketsBloc>()
                          .add(const FetchFirstPage<TicketEntity>()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final items = state is PaginationLoaded<TicketEntity>
                ? state.items
                : (state as PaginationError<TicketEntity>).previousItems;
            final isFetchingMore = state is PaginationLoaded<TicketEntity>
                ? state.isFetchingMore
                : false;

            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length + (isFetchingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _TicketListItem(
                  ticket: items[index],
                  onTap: () =>
                      context.push('/tickets/${items[index].id}', extra: items[index]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _TicketListItem extends StatelessWidget {
  final TicketEntity ticket;
  final VoidCallback onTap;

  const _TicketListItem({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (ticket.eventCoverUrl != null)
              SizedBox(
                width: 80,
                height: 80,
                child: CachedNetworkImage(
                  imageUrl: ticket.eventCoverUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: colorScheme.primaryContainer,
                    child: const Icon(Icons.event),
                  ),
                ),
              )
            else
              Container(
                width: 80,
                height: 80,
                color: colorScheme.primaryContainer,
                child: Icon(Icons.event, color: colorScheme.onPrimaryContainer),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.eventTitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ticket.ticketTypeName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(ticket.eventStartDate),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        _TicketStatusChip(status: ticket.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketStatusChip extends StatelessWidget {
  final TicketStatus status;
  const _TicketStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      TicketStatus.active => (Colors.green, 'Active'),
      TicketStatus.used => (Colors.blue, 'Used'),
      TicketStatus.cancelled => (Colors.red, 'Cancelled'),
      TicketStatus.refunded => (Colors.orange, 'Refunded'),
      TicketStatus.expired => (Colors.grey, 'Expired'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
