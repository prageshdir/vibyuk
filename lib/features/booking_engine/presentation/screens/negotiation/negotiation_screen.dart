import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/booking_engine/domain/entities/booking_negotiation_message_entity.dart';
import 'package:vibyuk/features/booking_engine/presentation/blocs/negotiation/negotiation_bloc.dart';
import 'package:vibyuk/features/booking_engine/presentation/widgets/negotiation_message_bubble.dart';

class NegotiationScreen extends StatefulWidget {
  const NegotiationScreen({
    super.key,
    required this.bookingId,
    required this.currentUserId,
  });

  final String bookingId;
  final String currentUserId;

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final _messageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _scrollController = ScrollController();
  NegotiationMessageType _selectedType = NegotiationMessageType.message;
  bool _showPriceField = false;

  @override
  void initState() {
    super.initState();
    context
        .read<NegotiationBloc>()
        .add(LoadNegotiationEvent(bookingId: widget.bookingId));
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _priceCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final message = _messageCtrl.text.trim();
    final price =
        _showPriceField ? double.tryParse(_priceCtrl.text.trim()) : null;

    if (!_showPriceField && message.isEmpty) return;
    if (_showPriceField && price == null) return;

    context.read<NegotiationBloc>().add(SendNegotiationEvent(
          bookingId: widget.bookingId,
          type: _selectedType,
          message: message.isEmpty ? null : message,
          offeredPrice: price,
          currency: 'INR',
        ));

    _messageCtrl.clear();
    _priceCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Negotiation',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<NegotiationBloc, NegotiationState>(
        listener: (context, state) {
          if (state is NegotiationLoadedState && !state.isSending) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        },
        builder: (context, state) => switch (state) {
          NegotiationLoadingState() =>
            const Center(child: AppLoader()),
          NegotiationLoadedState(:final messages, :final isSending) =>
            Column(
              children: [
                // Message type selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _TypeChip(
                        label: 'Message',
                        selected: _selectedType ==
                            NegotiationMessageType.message,
                        onTap: () => setState(() {
                          _selectedType = NegotiationMessageType.message;
                          _showPriceField = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        label: 'Counter-offer',
                        selected: _selectedType ==
                            NegotiationMessageType.counterOffer,
                        onTap: () => setState(() {
                          _selectedType =
                              NegotiationMessageType.counterOffer;
                          _showPriceField = true;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        label: 'Accept',
                        selected: _selectedType ==
                            NegotiationMessageType.acceptance,
                        color: Colors.green,
                        onTap: () => setState(() {
                          _selectedType =
                              NegotiationMessageType.acceptance;
                          _showPriceField = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        label: 'Reject',
                        selected: _selectedType ==
                            NegotiationMessageType.rejection,
                        color: Colors.red,
                        onTap: () => setState(() {
                          _selectedType =
                              NegotiationMessageType.rejection;
                          _showPriceField = false;
                        }),
                      ),
                    ],
                  ),
                ),

                // Messages list
                Expanded(
                  child: messages.isEmpty
                      ? Center(
                          child: Text('No messages yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onSurfaceVariant)),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: messages.length,
                          itemBuilder: (_, i) {
                            final msg = messages[i];
                            return NegotiationMessageBubble(
                              msg: msg,
                              isCurrentUser:
                                  msg.senderId == widget.currentUserId,
                            );
                          },
                        ),
                ),

                // Input area
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                        top: BorderSide(
                            color: theme.colorScheme.outlineVariant)),
                  ),
                  child: Column(
                    children: [
                      if (_showPriceField) ...[
                        TextField(
                          controller: _priceCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                                  decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Proposed Price',
                            prefixIcon: const Icon(
                                Icons.currency_rupee_rounded),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageCtrl,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                isDense: true,
                              ),
                              maxLines: null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: isSending ? null : _send,
                            style: FilledButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(12)),
                            child: isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white))
                                : const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          NegotiationErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.read<NegotiationBloc>().add(
                          LoadNegotiationEvent(
                              bookingId: widget.bookingId),
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? effectiveColor.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? effectiveColor
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? effectiveColor : null,
            fontWeight:
                selected ? FontWeight.w700 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
