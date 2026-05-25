import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_report.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_reports/admin_reports_bloc.dart';
import 'package:vibyuk/features/admin/presentation/widgets/cards/admin_report_card.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_search_bar.dart';
import 'package:vibyuk/features/admin/presentation/widgets/sheets/admin_report_action_sheet.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AdminReportsBloc>().add(AdminReportsFetch(refresh: true));
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<AdminReportsBloc>().add(AdminReportsLoadMore());
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
              'Platform Reports',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: _FilterBar(),
            ),
          ),
          BlocConsumer<AdminReportsBloc, AdminReportsState>(
            listener: (context, state) {
              if (state.handleSuccess != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.handleSuccess!),
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
              if (state.status == AdminReportsLoadStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.reports.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No reports found')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i == state.reports.length) {
                      return state.hasMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 24);
                    }
                    return AdminReportCard(
                      report: state.reports[i],
                      onTap: () => _openAction(context, state.reports[i]),
                    );
                  },
                  childCount: state.reports.length + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openAction(BuildContext context, AdminReport report) {
    context
        .read<AdminReportsBloc>()
        .add(AdminReportsSelectReport(report.id));

    AdminReportActionSheet.show(
      context,
      report: report,
      onSubmit: (action, note) {
        context.read<AdminReportsBloc>().add(
              AdminReportsHandleReport(
                reportId: report.id,
                action: action,
                note: note,
              ),
            );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminReportsBloc>();
    return BlocBuilder<AdminReportsBloc, AdminReportsState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminSearchBar(
              hint: 'Search reports...',
              onChanged: (q) => bloc.add(AdminReportsSearchChanged(q)),
              hasActiveFilter: state.statusFilter != null ||
                  state.categoryFilter != null,
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
                        bloc.add(AdminReportsStatusFilterChanged(null)),
                  ),
                  ...ReportStatus.values.map(
                    (s) => _Chip(
                      label: _label(s),
                      selected: state.statusFilter == s,
                      onTap: () =>
                          bloc.add(AdminReportsStatusFilterChanged(s)),
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

  String _label(ReportStatus s) => switch (s) {
        ReportStatus.pending => 'Pending',
        ReportStatus.underReview => 'In Review',
        ReportStatus.actionTaken => 'Actioned',
        ReportStatus.dismissed => 'Dismissed',
        ReportStatus.escalated => 'Escalated',
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
              ? const Color(0xFFFF8C42)
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
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
