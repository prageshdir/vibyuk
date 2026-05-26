import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_contract_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/contract/contract_bloc.dart';

class ContractScreen extends StatefulWidget {
  const ContractScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends State<ContractScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ContractBloc>()
        .add(LoadContractEvent(bookingId: widget.bookingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contract',
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          BlocBuilder<ContractBloc, ContractState>(
            builder: (context, state) {
              if (state is ContractLoadedState &&
                  state.contract.downloadUrl != null) {
                return IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: () {},
                  tooltip: 'Download',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ContractBloc, ContractState>(
        listener: (context, state) {
          if (state is ContractLoadedState) {
            if (state.signSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contract signed successfully!')),
              );
            } else if (state.signError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.signError!.message)),
              );
            }
          }
        },
        builder: (context, state) => switch (state) {
          ContractLoadingState() => const Center(child: AppLoader()),
          ContractLoadedState(:final contract, :final isSigning) =>
            _ContractView(
                contract: contract,
                isSigning: isSigning,
                onSign: () => context.read<ContractBloc>().add(
                      SignContractEvent(bookingId: widget.bookingId),
                    )),
          ContractErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<ContractBloc>().add(
                          LoadContractEvent(bookingId: widget.bookingId),
                        ),
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
}

class _ContractView extends StatelessWidget {
  const _ContractView({
    required this.contract,
    required this.isSigning,
    required this.onSign,
  });

  final BookingContractEntity contract;
  final bool isSigning;
  final VoidCallback onSign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Status banner
        _StatusBanner(contract: contract),

        // Contract text
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.contractText,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                ),

                if (contract.creatorSignedAt != null ||
                    contract.businessSignedAt != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Signatures',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (contract.creatorSignedAt != null)
                    _SignatureRow(
                      label: 'Creator',
                      signedAt: contract.creatorSignedAt!,
                    ),
                  if (contract.businessSignedAt != null)
                    _SignatureRow(
                      label: 'Business',
                      signedAt: contract.businessSignedAt!,
                    ),
                ],
              ],
            ),
          ),
        ),

        // Sign button
        if (contract.needsCreatorSignature && !contract.isFullyExecuted)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: isSigning ? null : onSign,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                child: isSigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Sign Contract'),
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.contract});
  final BookingContractEntity contract;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color, icon) = _config(contract.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static (String, Color, IconData) _config(ContractStatus s) =>
      switch (s) {
        ContractStatus.draft => ('Draft', Colors.grey, Icons.edit_outlined),
        ContractStatus.sentForSigning => (
            'Awaiting Signatures',
            Colors.orange,
            Icons.pending_outlined
          ),
        ContractStatus.signedByCreator => (
            'Signed by Creator',
            Colors.blue,
            Icons.draw_outlined
          ),
        ContractStatus.signedByBusiness => (
            'Signed by Business',
            Colors.blue,
            Icons.draw_outlined
          ),
        ContractStatus.fullyExecuted => (
            'Fully Executed',
            Colors.green,
            Icons.verified_rounded
          ),
        ContractStatus.voided => (
            'Voided',
            Colors.red,
            Icons.cancel_outlined
          ),
      };
}

class _SignatureRow extends StatelessWidget {
  const _SignatureRow({required this.label, required this.signedAt});
  final String label;
  final DateTime signedAt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.draw_outlined, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            '${signedAt.day}/${signedAt.month}/${signedAt.year}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
