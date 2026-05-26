import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/di/injection_container.dart';
import 'package:vibyuk/features/chat/presentation/blocs/chat/chat_bloc.dart';
import 'package:vibyuk/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:vibyuk/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:vibyuk/features/chat/presentation/widgets/typing_indicator.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.bookingId,
  });

  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String? bookingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()
        ..add(LoadMessagesEvent(
          conversationId: conversationId,
          otherUserId: otherUserId,
        )),
      child: _ChatView(
        otherUserName: otherUserName,
        otherUserAvatarUrl: otherUserAvatarUrl,
        bookingId: bookingId,
      ),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView({
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.bookingId,
  });
  final String otherUserName;
  final String? otherUserAvatarUrl;
  final String? bookingId;

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _BookingContextBanner extends StatelessWidget {
  const _BookingContextBanner({required this.bookingId});
  final String bookingId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.primaryContainer.withAlpha(128),
      child: Row(
        children: [
          Icon(Icons.lock_outline,
              size: 14, color: theme.colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'This conversation is part of booking $bookingId. '
              'Only booking parties can message here.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatViewState extends State<_ChatView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatBloc>().add(const LoadMoreMessagesEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        titleSpacing: 0,
        title: BlocBuilder<ChatBloc, ChatState>(
          buildWhen: (p, c) =>
              c is ChatLoadedState &&
              (p is! ChatLoadedState ||
                  (p as ChatLoadedState).isOtherUserOnline !=
                      (c as ChatLoadedState).isOtherUserOnline),
          builder: (context, state) {
            final isOnline =
                state is ChatLoadedState && state.isOtherUserOnline;
            return Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: widget.otherUserAvatarUrl != null
                          ? NetworkImage(widget.otherUserAvatarUrl!)
                          : null,
                      child: widget.otherUserAvatarUrl == null
                          ? Text(
                              widget.otherUserName.isNotEmpty
                                  ? widget.otherUserName[0].toUpperCase()
                                  : '?',
                              style:
                                  const TextStyle(color: AppColors.onPrimary),
                            )
                          : null,
                      backgroundColor: AppColors.primary,
                    ),
                    if (isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.surface, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.otherUserName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          if (widget.bookingId != null) _BookingContextBanner(bookingId: widget.bookingId!),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary));
                }
                if (state is ChatErrorState) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          state.failure.message,
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ChatLoadedState) {
                  return Column(
                    children: [
                      if (state.isOtherUserTyping)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: TypingIndicator(
                                userName: widget.otherUserName),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            return ChatMessageBubble(
                                message: state.messages[index]);
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          BlocBuilder<ChatBloc, ChatState>(
            buildWhen: (p, c) =>
                (p is ChatLoadedState) != (c is ChatLoadedState) ||
                (p is ChatLoadedState &&
                    c is ChatLoadedState &&
                    (p.uploadProgress != c.uploadProgress)),
            builder: (context, state) {
              final isSending =
                  state is ChatLoadedState && state.uploadProgress != null;
              final progress =
                  state is ChatLoadedState ? state.uploadProgress : null;
              return ChatInputBar(
                onSendText: (text) =>
                    context.read<ChatBloc>().add(SendTextMessageEvent(text)),
                onSendImage: (file) =>
                    context.read<ChatBloc>().add(SendImageEvent(file)),
                onSendFile: (file) =>
                    context.read<ChatBloc>().add(SendFileEvent(file)),
                onSendAudio: (file, duration) => context
                    .read<ChatBloc>()
                    .add(SendAudioEvent(
                        file: file, durationSeconds: duration)),
                onTypingStart: () =>
                    context.read<ChatBloc>().add(const StartTypingEvent()),
                onTypingStop: () =>
                    context.read<ChatBloc>().add(const StopTypingEvent()),
                isSending: isSending,
                uploadProgress: progress,
              );
            },
          ),
        ],
      ),
    );
  }
}
