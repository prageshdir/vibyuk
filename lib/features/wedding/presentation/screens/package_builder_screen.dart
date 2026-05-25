import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/package_builder/package_builder_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/package_builder_step_card.dart';

class PackageBuilderScreen extends StatefulWidget {
  final String? weddingId;
  const PackageBuilderScreen({super.key, this.weddingId});

  @override
  State<PackageBuilderScreen> createState() => _PackageBuilderScreenState();
}

class _PackageBuilderScreenState extends State<PackageBuilderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PackageBuilderBloc>().add(const PackageBuilderLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PackageBuilderBloc, PackageBuilderState>(
      listener: (context, state) {
        if (state is PackageBuilderSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Package "${state.package.name}" created!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
        if (state is PackageBuilderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Package Builder')),
        body: BlocBuilder<PackageBuilderBloc, PackageBuilderState>(
          builder: (context, state) => switch (state) {
            PackageBuilderInitial() ||
            PackageBuilderLoading() =>
              const Center(child: CircularProgressIndicator()),
            PackageBuilderError(:final failure) => Center(
                child: Text(failure.message),
              ),
            PackageBuilderSuccess() =>
              const Center(child: CircularProgressIndicator()),
            PackageBuilderLoaded() => _PackageList(
                state: state,
                weddingId: widget.weddingId,
              ),
          },
        ),
      ),
    );
  }
}

class _PackageList extends StatelessWidget {
  final PackageBuilderLoaded state;
  final String? weddingId;
  const _PackageList({required this.state, this.weddingId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choose a Package',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (state.packages.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No packages available'),
                  ),
                )
              else
                ...state.packages.map((pkg) => PackageBuilderStepCard(
                      package: pkg,
                      isSelected: state.selectedVendorIds
                          .containsAll(pkg.includedVendorIds),
                      onTap: () {
                        for (final vendorId in pkg.includedVendorIds) {
                          context.read<PackageBuilderBloc>().add(
                                PackageBuilderVendorToggled(vendorId: vendorId),
                              );
                        }
                      },
                    )),
            ],
          ),
        ),
        if (state.selectedVendorIds.isNotEmpty)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.selectedVendorIds.length} vendor(s) selected',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: state.isSubmitting
                        ? null
                        : () => _submitPackage(context),
                    icon: state.isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Build Custom Package'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _submitPackage(BuildContext context) {
    if (weddingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No wedding ID provided')),
      );
      return;
    }
    context.read<PackageBuilderBloc>().add(
          PackageBuilderCustomPackageSubmitted(weddingId: weddingId!),
        );
  }
}
