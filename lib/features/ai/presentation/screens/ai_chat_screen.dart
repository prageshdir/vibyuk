import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/features/ai/domain/entities/ai_chat_message.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_chat/ai_chat_bloc.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_chat/ai_chat_event.dart';
import 'package:vibyuk/features/ai/presentation/blocs/ai_chat/ai_chat_state.dart';
import 'package:vibyuk/features/ai/presentation/widgets/chat/ai_chat_bubble.dart';
import 'package:vibyuk/features/ai/presentation/widgets/chat/ai_chat_input.dart';
import 'package:vibyuk/features/ai/presentation/widgets/chat/ai_typing_indicator.dart';

class AiChatScreen extends StatefulWidget {
  final AiChatContext chatContext;

  const AiChatScreen({
    super.key,
    this.chatContext = AiChatContext.general,
  });

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AiChatBloc>().add(
          InitializeChat(context: widget.chatContext),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.tertiary],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Viby AI',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                Text(
                  _contextLabel(widget.chatContext),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<AiChatBloc>().add(const ClearChat());
              context.read<AiChatBloc>().add(
                    InitializeChat(context: widget.chatContext),
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => _showHistory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AiChatBloc, AiChatState>(
              listenWhen: (prev, curr) =>
                  curr.messages.length > prev.messages.length ||
                  curr.isTyping != prev.isTyping,
              listener: (_, __) => _scrollToBottom(),
              builder: (context, state) {
                if (state.status == AiChatStatus.initializing) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Starting conversation...'),
                      ],
                    ),
                  );
                }

                if (state.messages.isEmpty && !state.isTyping) {
                  return _WelcomeScreen(chatContext: widget.chatContext);
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: state.messages.length + (state.isTyping ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == state.messages.length && state.isTyping) {
                      return const AiTypingIndicator();
                    }
                    final msg = state.messages[i];
                    return AiChatBubble(
                      message: msg,
                      onRetry: msg.hasFailed
                          ? () => context
                              .read<AiChatBloc>()
                              .add(RetryFailedMessage(messageId: msg.id))
                          : null,
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<AiChatBloc, AiChatState>(
            builder: (context, state) {
              return AiChatInput(
                isEnabled: state.isReady,
                hintText: _hintText(widget.chatContext),
                onSubmit: (text) {
                  context
                      .read<AiChatBloc>()
                      .add(SendMessage(content: text));
                },
              );
            },
          ),
        ],
      ),
    );
  }

  String _contextLabel(AiChatContext ctx) {
    return switch (ctx) {
      AiChatContext.general => 'General Assistant',
      AiChatContext.recommendations => 'Creator Recommendations',
      AiChatContext.campaign => 'Campaign Planning',
      AiChatContext.pricing => 'Pricing Advisor',
      AiChatContext.analytics => 'Analytics Insights',
    };
  }

  String _hintText(AiChatContext ctx) {
    return switch (ctx) {
      AiChatContext.general => 'Ask Viby AI anything...',
      AiChatContext.recommendations => 'Describe your event...',
      AiChatContext.campaign => 'Describe your campaign goal...',
      AiChatContext.pricing => 'Ask about pricing strategies...',
      AiChatContext.analytics => 'Ask about your performance...',
    };
  }

  void _showHistory(BuildContext context) {
    context.read<AiChatBloc>().add(const LoadConversationHistory());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AiChatBloc>(),
        child: _HistorySheet(),
      ),
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final AiChatContext chatContext;

  const _WelcomeScreen({required this.chatContext});

  @override
  Widget build(BuildContext context) {
    final suggestions = _suggestions(chatContext);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.tertiary],
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hi, I\'m Viby AI',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Your intelligent creator platform assistant.\nHow can I help you today?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 28),
          ...suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SuggestionChip(
                text: s,
                onTap: () => context
                    .read<AiChatBloc>()
                    .add(SendMessage(content: s)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _suggestions(AiChatContext ctx) {
    return switch (ctx) {
      AiChatContext.general => [
          'What creators are available for a corporate event?',
          'Help me plan a birthday party with a budget of £2000',
          'What\'s trending in event entertainment this season?',
          'How do I get the best ROI from my event budget?',
        ],
      AiChatContext.recommendations => [
          'Find me a photographer for a wedding in London',
          'Who are the top DJs for corporate events?',
          'I need a speaker for a tech conference',
        ],
      AiChatContext.campaign => [
          'Create a 30-day campaign for my event launch',
          'What marketing channels work best for events?',
          'Help me build an influencer outreach strategy',
        ],
      AiChatContext.pricing => [
          'What should I charge for wedding photography?',
          'How does my pricing compare to the market?',
          'Should I offer packages or hourly rates?',
        ],
      AiChatContext.analytics => [
          'What are my top performing categories?',
          'Which creators drive the most revenue?',
          'What\'s my projected revenue for next quarter?',
        ],
    };
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).cardColor,
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 13)),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conversation History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          BlocBuilder<AiChatBloc, AiChatState>(
            builder: (context, state) {
              if (state.conversationHistory.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No previous conversations',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.conversationHistory.length,
                itemBuilder: (_, i) {
                  final conv = state.conversationHistory[i];
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: const Icon(Icons.chat_rounded,
                          size: 18, color: AppColors.primary),
                    ),
                    title: Text(conv.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      conv.lastMessage?.content ?? 'No messages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      context.read<AiChatBloc>().add(
                            SelectConversation(
                              conversationId: conv.id,
                            ),
                          );
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
