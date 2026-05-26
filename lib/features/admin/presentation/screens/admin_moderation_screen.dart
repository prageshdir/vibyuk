import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/admin/domain/entities/admin_user.dart';
import 'package:vibyuk/features/admin/presentation/bloc/admin_moderation/admin_moderation_bloc.dart';
import 'package:vibyuk/features/admin/presentation/widgets/cards/admin_user_card.dart';
import 'package:vibyuk/features/admin/presentation/widgets/common/admin_search_bar.dart';
import 'package:vibyuk/features/admin/presentation/widgets/sheets/admin_user_action_sheet.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AdminModerationBloc>().add(
          AdminModerationFetchUsers(refresh: true),
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
      context.read<AdminModerationBloc>().add(AdminModerationLoadMore());
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
              'User Moderation',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: _FilterBar(),
            ),
          ),
          BlocConsumer<AdminModerationBloc, AdminModerationState>(
            listener: (context, state) {
              if (state.moderationSuccess != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.moderationSuccess!),
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
              if (state.status == AdminModerationStatus.loading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.status == AdminModerationStatus.error &&
                  state.users.isEmpty) {
                return SliverFillRemaining(
                  child: _ErrorView(
                    message: state.errorMessage ?? 'Something went wrong',
                    onRetry: () => context
                        .read<AdminModerationBloc>()
                        .add(AdminModerationFetchUsers(refresh: true)),
                  ),
                );
              }

              if (state.users.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No users found')),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (i == state.users.length) {
                      return state.hasMore
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : const SizedBox(height: 24);
                    }
                    final user = state.users[i];
                    return AdminUserCard(
                      user: user,
                      onTap: () => _showDetail(context, user),
                      onActionTap: () => _showActionSheet(context, user),
                    );
                  },
                  childCount: state.users.length + 1,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, AdminUser user) {
    context
        .read<AdminModerationBloc>()
        .add(AdminModerationSelectUser(user.id));
    // Could push a detail screen — here we show action sheet
    _showActionSheet(context, user);
  }

  void _showActionSheet(BuildContext context, AdminUser user) {
    AdminUserActionSheet.show(
      context,
      user: user,
      onSubmit: (action, reason, duration, note) {
        context.read<AdminModerationBloc>().add(
              AdminModerationModerateUser(
                userId: user.id,
                action: action,
                reason: reason,
                suspensionDuration: duration,
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
    final bloc = context.read<AdminModerationBloc>();
    return BlocBuilder<AdminModerationBloc, AdminModerationState>(
      builder: (context, state) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminSearchBar(
              hint: 'Search users...',
              onChanged: (q) =>
                  bloc.add(AdminModerationSearchChanged(q)),
              hasActiveFilter: state.statusFilter != null ||
                  state.roleFilter != null,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: state.statusFilter == null,
                    onTap: () => bloc.add(
                      AdminModerationStatusFilterChanged(null),
                    ),
                  ),
                  ...AdminUserStatus.values.map(
                    (s) => _FilterChip(
                      label: _statusLabel(s),
                      selected: state.statusFilter == s,
                      onTap: () => bloc.add(
                        AdminModerationStatusFilterChanged(s),
                      ),
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

  String _statusLabel(AdminUserStatus s) => switch (s) {
        AdminUserStatus.active => 'Active',
        AdminUserStatus.suspended => 'Suspended',
        AdminUserStatus.banned => 'Banned',
        AdminUserStatus.pendingVerification => 'Pending',
        AdminUserStatus.deactivated => 'Deactivated',
      };
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
              ? const Color(0xFF7B2FFF)
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFFF5C6B)),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
