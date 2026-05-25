import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/business/presentation/blocs/discovery/discovery_bloc.dart';
import 'package:vibyuk/features/business/presentation/widgets/business_empty_state.dart';
import 'package:vibyuk/features/business/presentation/widgets/creator_list_tile.dart';

class SavedCreatorsScreen extends StatefulWidget {
  const SavedCreatorsScreen({super.key});

  @override
  State<SavedCreatorsScreen> createState() => _SavedCreatorsScreenState();
}

class _SavedCreatorsScreenState extends State<SavedCreatorsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const LoadSavedCreatorsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Creators',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) => switch (state) {
          DiscoveryLoadingState() =>
            const Center(child: AppLoader()),
          SavedCreatorsLoadedState(:final creators) => creators.isEmpty
              ? BusinessEmptyState(
                  title: 'No saved creators',
                  description:
                      'Tap the bookmark icon on a creator to save them here.',
                  icon: Icons.bookmark_border_rounded,
                  actionLabel: 'Discover creators',
                  onAction: () => context.pop(),
                )
              : ListView.separated(
                  itemCount: creators.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 76),
                  itemBuilder: (context, index) {
                    final creator = creators[index];
                    return CreatorListTile(
                      creator: creator,
                      onTap: () => context
                          .push('/discover/creators/${creator.id}'),
                      onSaveTap: () =>
                          context.read<DiscoveryBloc>().add(
                                ToggleSaveCreatorEvent(
                                  creatorId: creator.id,
                                  currentlySaved: creator.isSaved,
                                ),
                              ),
                    );
                  },
                ),
          DiscoveryErrorState(:final failure) =>
            BusinessEmptyState(
              title: 'Failed to load',
              description: failure.message,
              icon: Icons.error_outline_rounded,
              actionLabel: 'Retry',
              onAction: () => context
                  .read<DiscoveryBloc>()
                  .add(const LoadSavedCreatorsEvent()),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}
