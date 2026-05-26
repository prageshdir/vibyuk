import 'package:flutter/material.dart';

class TicketQuantitySelector extends StatelessWidget {
  const TicketQuantitySelector({
    super.key,
    required this.quantity,
    required this.max,
    this.onIncrement,
    this.onDecrement,
  });

  final int quantity;
  final int max;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final disabled = Theme.of(context).disabledColor;

    final canDecrement = quantity > 0;
    final canIncrement = quantity < max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: canDecrement ? onDecrement : null,
          icon: Icon(
            Icons.remove_circle_outline,
            color: canDecrement ? primary : disabled,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          splashRadius: 20,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          onPressed: canIncrement ? onIncrement : null,
          icon: Icon(
            Icons.add_circle_outline,
            color: canIncrement ? primary : disabled,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          splashRadius: 20,
        ),
      ],
    );
  }
}
