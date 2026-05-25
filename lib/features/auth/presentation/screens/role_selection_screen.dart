import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/features/auth/domain/entities/user_entity.dart';
import 'package:vibyuk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vibyuk/features/auth/presentation/widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  void _onRoleSelected(UserRole role) {
    setState(() => _selectedRole = role);
  }

  void _onContinue() {
    if (_selectedRole == null) return;
    context.read<AuthBloc>().add(SelectRoleEvent(role: _selectedRole!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthenticatedState():
            context.go(RouteNames.home);
          case AuthErrorState(:final failure):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          default:
            break;
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoadingState;
              final user = switch (state) {
                RoleSelectionRequiredState(:final user) => user,
                AuthenticatedState(:final user) => user,
                _ => null,
              };

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.brandGradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 24),
                          if (user != null) ...[
                            Text(
                              'Hey, ${user.firstName}! 👋',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            'How will you use\nVIBYUK?',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select your role to personalize your experience. You can always change this later.',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        RoleCard(
                          role: UserRole.creator,
                          isSelected: _selectedRole == UserRole.creator,
                          onTap: () => _onRoleSelected(UserRole.creator),
                        ),
                        const SizedBox(height: 16),
                        RoleCard(
                          role: UserRole.business,
                          isSelected: _selectedRole == UserRole.business,
                          onTap: () => _onRoleSelected(UserRole.business),
                        ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedOpacity(
                            opacity: _selectedRole != null ? 1.0 : 0.4,
                            duration: const Duration(milliseconds: 200),
                            child: PrimaryButton(
                              label: 'Continue',
                              onPressed: isLoading || _selectedRole == null ? null : _onContinue,
                              isLoading: isLoading,
                              leadingIcon: Icons.arrow_forward_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
