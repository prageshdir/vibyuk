import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/tourism/presentation/blocs/creator_collaboration/creator_collaboration_bloc.dart';
import 'package:vibyuk/features/tourism/presentation/widgets/creator_collab_card.dart';

class CreatorCollaborationScreen extends StatefulWidget {
  const CreatorCollaborationScreen({
    super.key,
    this.destinationId,
    this.campaignId,
  });

  final String? destinationId;
  final String? campaignId;

  @override
  State<CreatorCollaborationScreen> createState() =>
      _CreatorCollaborationScreenState();
}

class _CreatorCollaborationScreenState
    extends State<CreatorCollaborationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CreatorCollaborationBloc>().add(
          CollaborationListLoaded(
            destinationId: widget.destinationId,
            campaignId: widget.campaignId,
          ),
        );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<CreatorCollaborationBloc>()
          .add(const CollaborationNextPage());
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
        title: const Text('Creator Collaborations',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<CreatorCollaborationBloc>()
                .add(const CollaborationRefreshed()),
          ),
        ],
      ),
      body: BlocConsumer<CreatorCollaborationBloc, CreatorCollaborationState>(
        listenWhen: (p, c) => p.actionStatus != c.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == CollaborationActionStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Collaboration updated!'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state.actionStatus == CollaborationActionStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Action failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == CollaborationStatus2.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CollaborationStatus2.error &&
              state.collaborations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.outline),
                  const SizedBox(height: 16),
                  Text(state.errorMessage ?? 'Failed to load collaborations'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<CreatorCollaborationBloc>()
                        .add(const CollaborationRefreshed()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state.collaborations.isEmpty) {
            return const Center(
                child: Text('No collaborations found'));
          }

          return RefreshIndicator(
            onRefresh: () async => context
                .read<CreatorCollaborationBloc>()
                .add(const CollaborationRefreshed()),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.collaborations.length +
                  (state.isLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == state.collaborations.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final collab = state.collaborations[index];
                return CreatorCollabCard(collaboration: collab);
              },
            ),
          );
        },
      ),
    );
  }
}
