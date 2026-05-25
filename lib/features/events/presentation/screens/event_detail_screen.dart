import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_detail/event_detail_bloc.dart';
import 'package:vibyuk/features/events/presentation/widgets/capacity_bar_widget.dart';
import 'package:vibyuk/features/events/presentation/widgets/ticket_type_card.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _descriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EventDetailBloc>()
          .add(EventDetailLoadRequested(eventId: widget.eventId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventDetailBloc, EventDetailState>(
      listener: (context, state) {
        if (state is EventDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is EventDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is EventDetailError && state is! EventDetailLoaded) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.failure.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<EventDetailBloc>().add(
                          EventDetailLoadRequested(eventId: widget.eventId),
                        ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! EventDetailLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _EventDetailView(
          event: state.event,
          isPublishing: state.isPublishing,
          descriptionExpanded: _descriptionExpanded,
          onToggleDescription: () =>
              setState(() => _descriptionExpanded = !_descriptionExpanded),
        );
      },
    );
  }
}

class _EventDetailView extends StatelessWidget {
  final EventEntity event;
  final bool isPublishing;
  final bool descriptionExpanded;
  final VoidCallback onToggleDescription;

  const _EventDetailView({
    required this.event,
    required this.isPublishing,
    required this.descriptionExpanded,
    required this.onToggleDescription,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEE, MMM d • HH:mm');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: event.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: event.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: colorScheme.primaryContainer,
                        child: Icon(
                          Icons.event,
                          size: 64,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    )
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.event,
                        size: 64,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
            ),
            actions: [
              if (event.status == EventStatus.draft && !isPublishing)
                TextButton.icon(
                  onPressed: () => context
                      .read<EventDetailBloc>()
                      .add(const EventDetailPublishRequested()),
                  icon: const Icon(Icons.publish, color: Colors.white),
                  label: const Text('Publish',
                      style: TextStyle(color: Colors.white)),
                ),
              if (isPublishing)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.dashboard_outlined, color: Colors.white),
                onPressed: () =>
                    context.push('/events/${event.id}/dashboard'),
                tooltip: 'Dashboard',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _StatusChip(status: event.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: event.organizerAvatarUrl != null
                            ? CachedNetworkImageProvider(
                                event.organizerAvatarUrl!)
                            : null,
                        child: event.organizerAvatarUrl == null
                            ? Text(
                                event.organizerName.isNotEmpty
                                    ? event.organizerName[0]
                                    : '?',
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.organizerName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text:
                        '${dateFormat.format(event.startDate)} – ${dateFormat.format(event.endDate)}',
                  ),
                  const SizedBox(height: 8),
                  if (event.isOnline)
                    _InfoRow(
                      icon: Icons.videocam_outlined,
                      text: 'Online Event',
                    )
                  else
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      text: [event.venueName, event.venueAddress]
                          .where((s) => s != null && s.isNotEmpty)
                          .join(', '),
                    ),
                  const Divider(height: 24),
                  Text(
                    'About',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    maxLines: descriptionExpanded ? null : 3,
                    overflow: descriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  if (event.description.length > 120)
                    TextButton(
                      onPressed: onToggleDescription,
                      child: Text(
                          descriptionExpanded ? 'Show less' : 'Read more'),
                    ),
                  const Divider(height: 24),
                  Text(
                    'Tickets',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  ...event.ticketTypes
                      .where((t) => t.isVisible)
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TicketTypeCard(
                              ticketType: t,
                              quantity: 0,
                              isReadOnly: true,
                            ),
                          )),
                  const SizedBox(height: 12),
                  CapacityBarWidget(
                    sold: event.soldTickets,
                    total: event.totalCapacity,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(event: event),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final EventEntity event;
  const _BottomBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final priceText = event.minTicketPrice == null
        ? 'Free'
        : event.minTicketPrice == 0
            ? 'Free'
            : 'From \$${event.minTicketPrice!.toStringAsFixed(2)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Starting at',
                    style: Theme.of(context).textTheme.labelSmall),
                Text(
                  priceText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: event.isSoldOut || event.hasEnded
                    ? null
                    : () => context.push(
                          '/events/${event.id}/purchase',
                          extra: event,
                        ),
                child: Text(
                  event.isSoldOut
                      ? 'Sold Out'
                      : event.hasEnded
                          ? 'Event Ended'
                          : 'Get Tickets',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EventStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      EventStatus.published => (Colors.green, 'Published'),
      EventStatus.draft => (Colors.orange, 'Draft'),
      EventStatus.cancelled => (Colors.red, 'Cancelled'),
      EventStatus.ended => (Colors.grey, 'Ended'),
      EventStatus.soldOut => (Colors.purple, 'Sold Out'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
