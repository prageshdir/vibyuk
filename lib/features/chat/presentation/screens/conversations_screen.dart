import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/chat/presentation/blocs/conversations/conversations_bloc.dart';
import 'package:vibyuk/features/chat/presentation/widgets/conversation_tile.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ConversationsBloc>()..add(const LoadConversationsEvent()),
      child: const _ConversationsView(),
    );
  }
}

class _ConversationsView extends StatelessWidget {
  const _ConversationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => context
                .read<ConversationsBloc>()
                .add(const RefreshConversationsEvent()),
          ),
        ],
      ),
      body: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsLoadingState) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is ConversationsErrorState) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load conversations',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    onPressed: () => context
                        .read<ConversationsBloc>()
                        .add(const RefreshConversationsEvent()),
                    child: const Text('Retry',
                        style: TextStyle(color: AppColors.onPrimary)),
                  ),
                ],
              ),
            );
          }
          if (state is ConversationsLoadedState) {
            if (state.conversations.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 64, color: AppColors.outlineVariant),
                    SizedBox(height: 16),
                    Text(
                      'No conversations yet',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              itemCount: state.conversations.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final conv = state.conversations[index];
                return ConversationTile(
                  conversation: conv,
                  onTap: () {
                    context
                        .read<ConversationsBloc>()
                        .add(ConversationReadEvent(conv.id));
                    context.push(
                      RouteNames.chatConversation(conv.id),
                      extra: {
                        'conversationId': conv.id,
                        'otherUserId': conv.otherUserId,
                        'otherUserName': conv.otherUserName,
                        'otherUserAvatarUrl': conv.otherUserAvatarUrl,
                      },
                    );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
