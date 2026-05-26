import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/apply_for_fam_trip_usecase.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/fam_trip/fam_trip_bloc.dart';

class FamTripDetailScreen extends StatefulWidget {
  final String tripId;
  const FamTripDetailScreen({super.key, required this.tripId});

  @override
  State<FamTripDetailScreen> createState() => _FamTripDetailScreenState();
}

class _FamTripDetailScreenState extends State<FamTripDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FamTripBloc>().add(FamTripDetailLoaded(widget.tripId));
  }

  void _showApplyDialog(FamTripEntity trip) {
    final noteCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Apply for FAM Trip'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(
            labelText: 'Why do you want to join?',
            hintText: 'Tell the organiser about yourself...',
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FamTripBloc>().add(
                    FamTripApplicationSubmitted(
                      ApplyFamTripParams(
                        tripId: trip.id,
                        applicationNote: noteCtrl.text.trim(),
                      ),
                    ),
                  );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FamTripBloc, FamTripState>(
      listener: (context, state) {
        if (state.applicationStatus == FamTripApplicationStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state.applicationStatus == FamTripApplicationStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Application failed'),
            ),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<FamTripBloc, FamTripState>(
          builder: (context, state) {
            if (state.status == FamTripStateStatus.loading &&
                state.selectedTrip == null) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == FamTripStateStatus.error &&
                state.selectedTrip == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.errorMessage ?? 'Failed to load trip'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => context
                          .read<FamTripBloc>()
                          .add(FamTripDetailLoaded(widget.tripId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final trip = state.selectedTrip;
            if (trip == null) return const SizedBox.shrink();
            return _TripBody(trip: trip, onApply: trip.isOpen ? () => _showApplyDialog(trip) : null);
          },
        ),
      ),
    );
  }
}

class _TripBody extends StatelessWidget {
  final FamTripEntity trip;
  final VoidCallback? onApply;

  const _TripBody({required this.trip, this.onApply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: 260,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(trip.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            background: trip.coverImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: trip.coverImageUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                    ),
                  )
                : Container(color: theme.colorScheme.surfaceContainerHighest),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${_fmt(trip.departureDate)} – ${_fmt(trip.returnDate)} (${trip.durationDays} days)',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatusBadge(status: trip.status),
                  const SizedBox(width: 8),
                  Icon(Icons.people_outline, size: 14, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text('${trip.spotsRemaining} spots left',
                      style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Text('by ${trip.organizerName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Text(trip.description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              Text('Requirements',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _RequirementRow(
                icon: Icons.people,
                label: '${trip.requiredFollowerCount.toString()} followers minimum',
              ),
              if (trip.requiredNiches.isNotEmpty)
                _RequirementRow(
                  icon: Icons.category_outlined,
                  label: 'Niche: ${trip.requiredNiches.join(', ')}',
                ),
              if (trip.perks.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Perks Included',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...trip.perks.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 16, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(p, style: theme.textTheme.bodySmall)),
                        ],
                      ),
                    )),
              ],
              if (trip.itinerary.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Itinerary',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...trip.itinerary.map((day) => _ItineraryDay(day: day)),
              ],
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

class _StatusBadge extends StatelessWidget {
  final FamTripStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      FamTripStatus.upcoming => (AppColors.successContainer, AppColors.success, 'Open'),
      FamTripStatus.inProgress => (AppColors.primaryContainer, AppColors.primary, 'In Progress'),
      FamTripStatus.completed => (AppColors.surfaceVariant, AppColors.textSecondary, 'Completed'),
      FamTripStatus.cancelled => (AppColors.errorContainer, AppColors.error, 'Cancelled'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RequirementRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ItineraryDay extends StatelessWidget {
  final FamTripDayEntity day;
  const _ItineraryDay({required this.day});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text('${day.day}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.title,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (day.accommodation != null)
                  Text('Stay: ${day.accommodation}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      )),
                ...day.activities.map((a) => Row(
                      children: [
                        const Icon(Icons.circle, size: 4),
                        const SizedBox(width: 4),
                        Expanded(
                            child: Text(a, style: theme.textTheme.bodySmall)),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
