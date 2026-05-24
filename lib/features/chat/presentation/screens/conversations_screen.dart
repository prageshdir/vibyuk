import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/empty/empty_view.dart';
import 'package:vibyuk/core/widgets/error/error_view.dart';
import 'package:vibyuk/core/widgets/loaders/skeleton_loader.dart';
import 'package:vibyuk/features/chat/presentation/blocs/conversations/conversations_bloc.dart';
import 'package:vibyuk/features/chat/presentation/widgets/conversation_tile.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<ConversationsBloc>()
        .add(const LoadConversationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square_outlined),
            tooltip: 'New message',
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsLoadingState) {
            return _buildSkeleton();
          }
          if (state is ConversationsErrorState) {
            return ErrorView(
              message: state.failure.message,
              onRetry: () => context
                  .read<ConversationsBloc>()
                  .add(const LoadConversationsEvent()),
            );
          }
          if (state is ConversationsLoadedState) {
            if (state.conversations.isEmpty) {
              return const EmptyView(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No conversations yet',
                subtitle:
                    'Start a conversation by visiting a creator or business profile.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context
                  .read<ConversationsBloc>()
                  .add(const RefreshConversationsEvent()),
              child: ListView.separated(
                itemCount: state.conversations.length,
                separatorBuilder: (_, __) => const Divider(
                    height: 1, indent: 70, endIndent: 16),
                itemBuilder: (context, i) {
                  final conv = state.conversations[i];
                  return ConversationTile(
                    conversation: conv,
                    onTap: () {
                      context
                          .read<ConversationsBloc>()
                          .add(ConversationReadEvent(conv.id));
                      context.push('/messages/${conv.id}',
                          extra: conv);
                    },
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, indent: 70, endIndent: 16),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SkeletonLoader(width: 52, height: 52, radius: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 140, height: 14, radius: 7),
                  const SizedBox(height: 6),
                  SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 12,
                      radius: 6),
                ],
              ),
            ),
            const SkeletonLoader(width: 36, height: 12, radius: 6),
          ],
        ),
      ),
    );
  }
}
