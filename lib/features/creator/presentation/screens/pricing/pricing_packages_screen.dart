import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/pricing/pricing_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/creator_empty_state.dart';
import 'package:vibyuk/features/creator/presentation/widgets/pricing_package_card.dart';

class PricingPackagesScreen extends StatefulWidget {
  const PricingPackagesScreen({super.key});

  @override
  State<PricingPackagesScreen> createState() => _PricingPackagesScreenState();
}

class _PricingPackagesScreenState extends State<PricingPackagesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PricingBloc>().add(const LoadPricingPackagesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing Packages',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(RouteNames.addPricingPackage),
          ),
        ],
      ),
      body: BlocBuilder<PricingBloc, PricingState>(
        builder: (context, state) => switch (state) {
          PricingLoadingState() => const Center(child: AppLoader()),
          PricingLoadedState(:final packages) => packages.isEmpty
              ? CreatorEmptyState.noPricingPackages(
                  key: ValueKey('empty'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: packages.length,
                  itemBuilder: (context, i) {
                    final pkg = packages[i];
                    return PricingPackageCard(
                      package: pkg,
                      isEditable: true,
                      onEdit: () => context.push(
                          RouteNames.editPricingPackage(pkg.id),
                          extra: pkg),
                      onDelete: () => _confirmDelete(context, pkg),
                    );
                  },
                ),
          PricingErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<PricingBloc>()
                        .add(const LoadPricingPackagesEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          _ => const SizedBox.shrink(),
        },
      ),
      floatingActionButton: BlocBuilder<PricingBloc, PricingState>(
        builder: (context, state) {
          if (state is PricingLoadedState && state.packages.isNotEmpty) {
            return FloatingActionButton(
              onPressed: () => context.push(RouteNames.addPricingPackage),
              child: const Icon(Icons.add_rounded),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, PricingPackageEntity pkg) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete package?'),
        content: Text('Delete "${pkg.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<PricingBloc>()
                  .add(DeletePricingPackageEvent(packageId: pkg.id));
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
