import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_dispute.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_disputes/admin_disputes_bloc.dart';
import 'package:vibyuk/features/admin/presentation/widgets/cards/admin_dispute_card.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_search_bar.dart';
import 'package:vibyuk/features/admin/presentation/widgets/sheets/admin_dispute_detail_sheet.dart';

class AdminDisputesScreen extends StatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  State<AdminDisputesScreen> createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AdminDisputesBloc>().add(
          AdminDisputesFetchDisputes(refresh: true),
        );
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<AdminDisputesBloc>().add(AdminDisputesLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(
              'Disputes',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: _FilterBar(),
            ),
          ),
          BlocConsumer<AdminDisputesBloc, AdminDisputesState>(
            listener: (context, state) {
              if (state.actionSuccess != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.actionSuccess!),
                    backgroundColor: const Color(0xFF00D9C0),
                  ),
                );
              }
              if (state.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage!),
                    backgroundColor: const Color(0xFFFF5C6B),
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state.status == AdminDisputesStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.disputes.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No disputes found')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i == state.disputes.length) {
                      return state.hasMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 24);
                    }
                    return AdminDisputeCard(
                      dispute: state.disputes[i],
                      onTap: () =>
                          _openDetail(context, state.disputes[i]),
                    );
                  },
                  childCount: state.disputes.length + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, AdminDispute dispute) {
    context
        .read<AdminDisputesBloc>()
        .add(AdminDisputesSelectDispute(dispute.id));

    AdminDisputeDetailSheet.show(
      context,
      dispute: dispute,
      onResolve: (resolution, note, refundAmount) {
        context.read<AdminDisputesBloc>().add(
              AdminDisputesResolve(
                disputeId: dispute.id,
                resolution: resolution,
                note: note,
                refundAmount: refundAmount,
              ),
            );
      },
      onSendMessage: (content) {
        context.read<AdminDisputesBloc>().add(
              AdminDisputesSendMessage(
                disputeId: dispute.id,
                content: content,
              ),
            );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminDisputesBloc>();
    return BlocBuilder<AdminDisputesBloc, AdminDisputesState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminSearchBar(
              hint: 'Search disputes...',
              onChanged: (q) => bloc.add(AdminDisputesSearchChanged(q)),
              hasActiveFilter: state.statusFilter != null || state.typeFilter != null,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _Chip(
                    label: 'All',
                    selected: state.statusFilter == null,
                    onTap: () =>
                        bloc.add(AdminDisputesStatusFilterChanged(null)),
                  ),
                  ...DisputeStatus.values.map(
                    (s) => _Chip(
                      label: _label(s),
                      selected: state.statusFilter == s,
                      onTap: () =>
                          bloc.add(AdminDisputesStatusFilterChanged(s)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(DisputeStatus s) => switch (s) {
        DisputeStatus.open => 'Open',
        DisputeStatus.inReview => 'In Review',
        DisputeStatus.pendingInfo => 'Pending',
        DisputeStatus.resolved => 'Resolved',
        DisputeStatus.closed => 'Closed',
        DisputeStatus.escalated => 'Escalated',
      };
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFFF5C6B)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
