import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/blocs/vendor_detail/vendor_detail_bloc.dart';
import 'package:vibyuk/features/wedding/presentation/widgets/vendor_status_badge.dart';
import 'package:vibyuk/features/wedding/domain/entities/wedding_booking_entity.dart';

class VendorDetailScreen extends StatefulWidget {
  final String vendorId;
  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<VendorDetailBloc>()
        .add(VendorDetailLoadRequested(vendorId: widget.vendorId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VendorDetailBloc, VendorDetailState>(
      listener: (context, state) {
        if (state is VendorDetailBookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking request submitted!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
        if (state is VendorDetailError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<VendorDetailBloc, VendorDetailState>(
          builder: (context, state) => switch (state) {
            VendorDetailInitial() ||
            VendorDetailLoading() =>
              const Center(child: CircularProgressIndicator()),
            VendorDetailError(:final failure) => Center(
                child: Text(failure.message),
              ),
            VendorDetailBookingSuccess() =>
              const Center(child: CircularProgressIndicator()),
            VendorDetailLoaded(:final vendor, :final isBooking) =>
              CustomScrollView(
                slivers: [
                  SliverAppBar.large(
                    expandedHeight: 280,
                    flexibleSpace: FlexibleSpaceBar(
                      background: vendor.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: vendor.imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey[300]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vendor.name,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            if (vendor.isVerified)
                              const Icon(Icons.verified, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${vendor.rating.toStringAsFixed(1)} (${vendor.reviewCount} reviews)'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(vendor.location),
                        const SizedBox(height: 8),
                        Chip(label: Text(vendor.category.replaceAll('_', ' '))),
                        const SizedBox(height: 16),
                        Text(
                          vendor.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Price Range',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vendor.priceRange,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
          },
        ),
        bottomNavigationBar: BlocBuilder<VendorDetailBloc, VendorDetailState>(
          builder: (context, state) {
            if (state is! VendorDetailLoaded) return const SizedBox.shrink();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: state.isBooking
                      ? null
                      : () => _showBookingDialog(context),
                  child: state.isBooking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Request Booking'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => _BookingDialog(
        onSubmit: (weddingId, price, date, deposit, notes) {
          context.read<VendorDetailBloc>().add(VendorDetailBookingRequested(
                weddingId: weddingId,
                agreedPrice: price,
                eventDate: date,
                depositAmount: deposit,
                notes: notes,
              ));
        },
      ),
    );
  }
}

class _BookingDialog extends StatefulWidget {
  final Function(String, double, DateTime, double?, String?) onSubmit;
  const _BookingDialog({required this.onSubmit});

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weddingIdCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _eventDate = DateTime.now().add(const Duration(days: 180));

  @override
  void dispose() {
    _weddingIdCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Booking'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _weddingIdCtrl,
                decoration: const InputDecoration(labelText: 'Wedding ID *'),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Agreed Price *'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (double.tryParse(v!) == null) return 'Invalid amount';
                  return null;
                },
              ),
              TextFormField(
                controller: _depositCtrl,
                decoration: const InputDecoration(labelText: 'Deposit Amount'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            Navigator.of(context).pop();
            widget.onSubmit(
              _weddingIdCtrl.text,
              double.parse(_priceCtrl.text),
              _eventDate,
              _depositCtrl.text.isEmpty ? null : double.tryParse(_depositCtrl.text),
              _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
            );
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
