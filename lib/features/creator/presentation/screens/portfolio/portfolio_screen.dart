import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_empty_state.dart';
import 'package:vibyuk/features/creator/presentation/widgets/portfolio_item_card.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PortfolioBloc>().add(const LoadPortfolioEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.85) {
      context.read<PortfolioBloc>().add(const LoadMorePortfolioEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RouteNames.addPortfolioItem),
          ),
        ],
      ),
      body: BlocConsumer<PortfolioBloc, PortfolioState>(
        listener: (context, state) {
          if (state is PortfolioLoadedState && state.uploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item added to portfolio')),
            );
          }
        },
        builder: (context, state) => switch (state) {
          PortfolioLoadingState() => const Center(child: AppLoader()),
          PortfolioLoadedState(:final items, :final isLoadingMore) =>
            items.isEmpty
                ? CreatorEmptyState.noPortfolio(
                    key: ValueKey('empty'),
                  )
                : RefreshIndicator(
                    onRefresh: () async => context
                        .read<PortfolioBloc>()
                        .add(const LoadPortfolioEvent()),
                    child: PortfolioGrid(
                      items: items,
                      scrollController: _scrollController,
                      onItemDelete: (id) {
                        showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete item?'),
                            content: const Text(
                                'This will permanently remove it from your portfolio.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ).then((confirmed) {
                          if (confirmed == true) {
                            context
                                .read<PortfolioBloc>()
                                .add(DeletePortfolioItemEvent(itemId: id));
                          }
                        });
                      },
                    ),
                  ),
          PortfolioErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<PortfolioBloc>()
                        .add(const LoadPortfolioEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
      floatingActionButton: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, state) {
          if (state is PortfolioLoadedState && state.items.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => context.push(RouteNames.addPortfolioItem),
              child: const Icon(Icons.add_rounded),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
