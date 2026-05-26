import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/booking_request_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/booking_requests/booking_requests_bloc.dart';

class BookingRequestDetailScreen extends StatelessWidget {
  const BookingRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Request',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocBuilder<BookingRequestsBloc, BookingRequestsState>(
        builder: (context, state) {
          if (state is BookingRequestsLoadedState &&
              state.isLoadingDetail) {
            return const Center(child: AppLoader());
          }
          if (state is BookingRequestsLoadedState &&
              state.selectedRequest != null) {
            return _RequestDetailBody(request: state.selectedRequest!);
          }
          return const Center(child: AppLoader());
        },
      ),
    );
  }
}

class _RequestDetailBody extends StatelessWidget {
  const _RequestDetailBody({required this.request});
  final BookingRequestEntity request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business header
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: request.businessLogoUrl != null
                    ? NetworkImage(request.businessLogoUrl!)
                    : null,
                child: request.businessLogoUrl == null
                    ? Text(request.businessName[0].toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.businessName,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text(request.campaignTitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Details card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _DetailRow(label: 'Package', value: request.packageTitle),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Offered Price',
                    value:
                        '${request.currency} ${request.offeredPrice.toStringAsFixed(2)}',
                    valueColor: AppColors.primary,
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Delivery Date',
                    value:
                        '${request.requestedDeliveryDate.day}/${request.requestedDeliveryDate.month}/${request.requestedDeliveryDate.year}',
                  ),
                  const Divider(height: 24),
                  _DetailRow(
                    label: 'Expires',
                    value: request.isExpired
                        ? 'Expired'
                        : '${request.expiresAt.day}/${request.expiresAt.month}/${request.expiresAt.year}',
                    valueColor: request.isExpired ? Colors.red : null,
                  ),
                ],
              ),
            ),
          ),

          // Message
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Message',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(request.message!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
            ),
          ],

          // Counter offer details
          if (request.status == BookingRequestStatus.counterOffered) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded,
                          color: Colors.blue, size: 18),
                      const SizedBox(width: 6),
                      Text('Counter Offer',
                          style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  if (request.counterOfferPrice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${request.currency} ${request.counterOfferPrice!.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ],
                  if (request.counterOfferMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(request.counterOfferMessage!,
                        style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],

          // Action buttons
          if (request.canRespond) ...[
            const SizedBox(height: 24),
            _RespondActions(request: request),
          ],
        ],
      ),
    );
  }
}

class _RespondActions extends StatefulWidget {
  const _RespondActions({required this.request});
  final BookingRequestEntity request;

  @override
  State<_RespondActions> createState() => _RespondActionsState();
}

class _RespondActionsState extends State<_RespondActions> {
  bool _showCounterOffer = false;
  final _priceCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingRequestsBloc, BookingRequestsState>(
      builder: (context, state) {
        final isResponding =
            state is BookingRequestsLoadedState && state.isResponding;
        return Column(
          children: [
            if (_showCounterOffer) ...[
              AppTextField(
                controller: _priceCtrl,
                label: 'Counter Offer Price',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _msgCtrl,
                label: 'Message (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _showCounterOffer = false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: isResponding
                          ? null
                          : () {
                              context
                                  .read<BookingRequestsBloc>()
                                  .add(RespondToBookingRequestEvent(
                                    requestId: widget.request.id,
                                    accept: false,
                                    counterOfferPrice:
                                        double.tryParse(_priceCtrl.text),
                                    counterOfferMessage:
                                        _msgCtrl.text.trim().isEmpty
                                            ? null
                                            : _msgCtrl.text.trim(),
                                  ));
                            },
                      child: const Text('Send Counter'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isResponding
                          ? null
                          : () => context
                              .read<BookingRequestsBloc>()
                              .add(RespondToBookingRequestEvent(
                                requestId: widget.request.id,
                                accept: false,
                              )),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isResponding
                          ? null
                          : () =>
                              setState(() => _showCounterOffer = true),
                      child: const Text('Counter'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: isResponding
                          ? null
                          : () => context
                              .read<BookingRequestsBloc>()
                              .add(RespondToBookingRequestEvent(
                                requestId: widget.request.id,
                                accept: true,
                              )),
                      child: isResponding
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        Text(value,
            style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }
}
