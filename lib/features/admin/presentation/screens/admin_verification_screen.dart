import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_verification.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_verification/admin_verification_bloc.dart';
import 'package:vibyuk/features/admin/presentation/widgets/cards/admin_verification_card.dart';
import 'package:vibyuk/features/admin/presentation/widgets/sheets/admin_verification_review_sheet.dart';

class AdminVerificationScreen extends StatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final TabController _tabs;

  static const _statusTabs = [
    null,
    VerificationStatus.pending,
    VerificationStatus.underReview,
    VerificationStatus.approved,
    VerificationStatus.rejected,
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statusTabs.length, vsync: this);
    _tabs.addListener(_onTabChange);
    context.read<AdminVerificationBloc>().add(AdminVerificationFetch(refresh: true));
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _tabs.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      context.read<AdminVerificationBloc>().add(AdminVerificationLoadMore());
    }
  }

  void _onTabChange() {
    if (_tabs.indexIsChanging) return;
    context.read<AdminVerificationBloc>().add(
          AdminVerificationStatusFilterChanged(_statusTabs[_tabs.index]),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scroll,
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            pinned: true,
            title: const Text(
              'Verifications',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'In Review'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
        body: BlocConsumer<AdminVerificationBloc, AdminVerificationState>(
          listener: (context, state) {
            if (state.reviewSuccess != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.reviewSuccess!),
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
            if (state.status == AdminVerificationStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.verifications.isEmpty) {
              return const Center(child: Text('No verifications found'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AdminVerificationBloc>()
                    .add(AdminVerificationFetch(refresh: true));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.verifications.length + 1,
                itemBuilder: (_, i) {
                  if (i == state.verifications.length) {
                    return state.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox(height: 24);
                  }
                  return AdminVerificationCard(
                    verification: state.verifications[i],
                    onTap: () =>
                        _openReview(context, state.verifications[i]),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _openReview(BuildContext context, AdminVerification verification) {
    context
        .read<AdminVerificationBloc>()
        .add(AdminVerificationSelect(verification.id));

    AdminVerificationReviewSheet.show(
      context,
      verification: verification,
      onSubmit: (decision, note, rejectionReason) {
        context.read<AdminVerificationBloc>().add(
              AdminVerificationReview(
                verificationId: verification.id,
                decision: decision,
                note: note,
                rejectionReason: rejectionReason,
              ),
            );
      },
    );
  }
}
