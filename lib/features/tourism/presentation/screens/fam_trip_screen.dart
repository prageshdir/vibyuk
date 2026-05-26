import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/domain/entities/fam_trip_entity.dart';
import 'package:vibyuk/features/tourism/domain/usecases/apply_for_fam_trip_usecase.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/fam_trip/fam_trip_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/fam_trip_card.dart';

class FamTripScreen extends StatefulWidget {
  const FamTripScreen({super.key, this.destinationId});

  final String? destinationId;

  @override
  State<FamTripScreen> createState() => _FamTripScreenState();
}

class _FamTripScreenState extends State<FamTripScreen> {
  final _scrollController = ScrollController();
  FamTripStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<FamTripBloc>().add(
          FamTripListLoaded(
            destinationId: widget.destinationId,
            status: FamTripStatus.upcoming,
          ),
        );
    _selectedStatus = FamTripStatus.upcoming;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FamTripBloc>().add(const FamTripNextPage());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator FAM Trips',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          PopupMenuButton<FamTripStatus?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() => _selectedStatus = status);
              context.read<FamTripBloc>().add(
                    FamTripListLoaded(
                      destinationId: widget.destinationId,
                      status: status,
                    ),
                  );
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('All Trips')),
              const PopupMenuItem(
                  value: FamTripStatus.upcoming, child: Text('Upcoming')),
              const PopupMenuItem(
                  value: FamTripStatus.inProgress,
                  child: Text('In Progress')),
              const PopupMenuItem(
                  value: FamTripStatus.completed, child: Text('Completed')),
            ],
          ),
        ],
      ),
      body: BlocConsumer<FamTripBloc, FamTripState>(
        listenWhen: (p, c) =>
            p.applicationStatus != c.applicationStatus,
        listener: (context, state) {
          if (state.applicationStatus == FamTripApplicationStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Application submitted successfully!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state.applicationStatus ==
              FamTripApplicationStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    state.errorMessage ?? 'Failed to submit application'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FamTripStateStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == FamTripStateStatus.error &&
              state.trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load trips'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<FamTripBloc>()
                        .add(const FamTripRefreshed()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.trips.isEmpty) {
            return const Center(child: Text('No FAM trips available'));
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<FamTripBloc>().add(const FamTripRefreshed()),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.trips.length + (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == state.trips.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final trip = state.trips[index];
                return FamTripCard(
                  trip: trip,
                  onTap: () => context.push(RouteNames.famTripDetailPath(trip.id)),
                  onApply: trip.isOpen
                      ? () => _showApplyDialog(context, trip)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showApplyDialog(BuildContext context, FamTripEntity trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<FamTripBloc>(),
        child: _ApplySheet(trip: trip),
      ),
    );
  }
}

class _ApplySheet extends StatefulWidget {
  const _ApplySheet({required this.trip});

  final FamTripEntity trip;

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _formKey = GlobalKey<FormState>();
  final _bioController = TextEditingController();
  final _followersController = TextEditingController();
  final _motivationController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    _followersController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Apply: ${widget.trip.title}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Min. ${widget.trip.requiredFollowerCount ~/ 1000}K followers required',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Creator Bio',
                  hintText: 'Describe your content style…',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Bio is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _followersController,
                decoration: const InputDecoration(
                  labelText: 'Follower Count',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final count = int.tryParse(v) ?? 0;
                  if (count < widget.trip.requiredFollowerCount) {
                    return 'Minimum ${widget.trip.requiredFollowerCount ~/ 1000}K required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _motivationController,
                decoration: const InputDecoration(
                  labelText: 'Why do you want to join? (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              BlocBuilder<FamTripBloc, FamTripState>(
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state.isApplying ? null : _submit,
                      child: state.isApplying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Submit Application'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<FamTripBloc>().add(
          FamTripApplicationSubmitted(
            ApplyFamTripParams(
              tripId: widget.trip.id,
              creatorBio: _bioController.text.trim(),
              followersCount: int.parse(_followersController.text.trim()),
              niches: widget.trip.requiredNiches,
              motivation: _motivationController.text.trim().isEmpty
                  ? null
                  : _motivationController.text.trim(),
            ),
          ),
        );
    Navigator.of(context).pop();
  }
}
