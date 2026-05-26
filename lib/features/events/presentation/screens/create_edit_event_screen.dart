import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:vibyuk/features/events/domain/entities/event_entity.dart';
import 'package:vibyuk/features/events/domain/entities/event_form_data.dart';
import 'package:vibyuk/features/events/domain/entities/ticket_type_entity.dart';
import 'package:vibyuk/features/events/presentation/blocs/event_form/event_form_bloc.dart';

class CreateEditEventScreen extends StatefulWidget {
  final String? eventId;
  const CreateEditEventScreen({super.key, this.eventId});

  @override
  State<CreateEditEventScreen> createState() => _CreateEditEventScreenState();
}

class _CreateEditEventScreenState extends State<CreateEditEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _venueAddressController = TextEditingController();
  final _streamUrlController = TextEditingController();
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EventFormBloc>()
          .add(const EventFormInitialized(existing: null));
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _streamUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventFormBloc, EventFormState>(
      listener: (context, state) {
        if (state is EventFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.isEdit
                  ? 'Event updated successfully!'
                  : 'Event created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
        if (state is EventFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final data = state is EventFormEditing
            ? state.data
            : const EventFormData();
        final isSubmitting =
            state is EventFormEditing && state.isSubmitting;

        return Scaffold(
          appBar: AppBar(
            title:
                Text(widget.eventId == null ? 'Create Event' : 'Edit Event'),
          ),
          body: Column(
            children: [
              _StepIndicator(currentStep: data.currentStep),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildStep(context, data),
                ),
              ),
              _BottomNavBar(
                currentStep: data.currentStep,
                isSubmitting: isSubmitting,
                canNext: _canGoNext(data),
                onBack: () => context.read<EventFormBloc>().add(
                      EventFormStepChanged(step: data.currentStep - 1),
                    ),
                onNext: () => _onNextOrSubmit(context, data),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _canGoNext(EventFormData data) {
    return switch (data.currentStep) {
      0 => data.isStep0Valid,
      1 => data.isStep1Valid,
      2 => data.isStep2Valid,
      _ => false,
    };
  }

  void _onNextOrSubmit(BuildContext context, EventFormData data) {
    if (data.currentStep < 2) {
      context
          .read<EventFormBloc>()
          .add(EventFormStepChanged(step: data.currentStep + 1));
    } else {
      context.read<EventFormBloc>().add(const EventFormSubmitted());
    }
  }

  Widget _buildStep(BuildContext context, EventFormData data) {
    return switch (data.currentStep) {
      0 => _Step0Details(
          data: data,
          titleController: _titleController,
          descController: _descController,
          formKey: _formKey0,
          onPickImage: () => _pickCoverImage(context),
        ),
      1 => _Step1DateVenue(
          data: data,
          venueNameController: _venueNameController,
          venueAddressController: _venueAddressController,
          streamUrlController: _streamUrlController,
          formKey: _formKey1,
        ),
      2 => _Step2Tickets(data: data),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _pickCoverImage(BuildContext context) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null && context.mounted) {
      context
          .read<EventFormBloc>()
          .add(EventFormCoverImageSelected(filePath: image.path));
    }
  }
}

// ---------------------------------------------------------------------------
// Step 0 — Details
// ---------------------------------------------------------------------------

class _Step0Details extends StatelessWidget {
  final EventFormData data;
  final TextEditingController titleController;
  final TextEditingController descController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onPickImage;

  const _Step0Details({
    required this.data,
    required this.titleController,
    required this.descController,
    required this.formKey,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    titleController.text = data.title;
    descController.text = data.description;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title *',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => context.read<EventFormBloc>().add(
                  EventFormDataUpdated(data: data.copyWith(title: v)),
                ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => context.read<EventFormBloc>().add(
                  EventFormDataUpdated(data: data.copyWith(description: v)),
                ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Description is required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<EventCategory>(
            value: data.category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: EventCategory.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                    ))
                .toList(),
            onChanged: (c) {
              if (c != null) {
                context.read<EventFormBloc>().add(
                      EventFormDataUpdated(data: data.copyWith(category: c)),
                    );
              }
            },
          ),
          const SizedBox(height: 20),
          Text('Cover Image',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  style: BorderStyle.solid,
                ),
              ),
              child: data.coverImagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(data.coverImagePath!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to select cover image',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1 — Date & Venue
// ---------------------------------------------------------------------------

class _Step1DateVenue extends StatelessWidget {
  final EventFormData data;
  final TextEditingController venueNameController;
  final TextEditingController venueAddressController;
  final TextEditingController streamUrlController;
  final GlobalKey<FormState> formKey;

  const _Step1DateVenue({
    required this.data,
    required this.venueNameController,
    required this.venueAddressController,
    required this.streamUrlController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    venueNameController.text = data.venueName;
    venueAddressController.text = data.venueAddress;
    streamUrlController.text = data.streamUrl;
    final fmt = DateFormat('MMM d, yyyy • HH:mm');

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DatePickerField(
            label: 'Start Date & Time *',
            value: data.startDate,
            onPicked: (dt) => context.read<EventFormBloc>().add(
                  EventFormDataUpdated(data: data.copyWith(startDate: dt)),
                ),
            formatter: fmt,
          ),
          const SizedBox(height: 16),
          _DatePickerField(
            label: 'End Date & Time *',
            value: data.endDate,
            onPicked: (dt) => context.read<EventFormBloc>().add(
                  EventFormDataUpdated(data: data.copyWith(endDate: dt)),
                ),
            formatter: fmt,
            minDate: data.startDate,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Online Event'),
            value: data.isOnline,
            onChanged: (v) => context.read<EventFormBloc>().add(
                  EventFormDataUpdated(data: data.copyWith(isOnline: v)),
                ),
          ),
          if (data.isOnline) ...[
            TextFormField(
              controller: streamUrlController,
              decoration: const InputDecoration(
                labelText: 'Stream URL',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (v) => context.read<EventFormBloc>().add(
                    EventFormDataUpdated(data: data.copyWith(streamUrl: v)),
                  ),
            ),
          ] else ...[
            TextFormField(
              controller: venueNameController,
              decoration: const InputDecoration(
                labelText: 'Venue Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              onChanged: (v) => context.read<EventFormBloc>().add(
                    EventFormDataUpdated(data: data.copyWith(venueName: v)),
                  ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Venue name required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: venueAddressController,
              decoration: const InputDecoration(
                labelText: 'Venue Address',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => context.read<EventFormBloc>().add(
                    EventFormDataUpdated(data: data.copyWith(venueAddress: v)),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final void Function(DateTime) onPicked;
  final DateFormat formatter;
  final DateTime? minDate;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onPicked,
    required this.formatter,
    this.minDate,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: value ?? minDate ?? now,
      firstDate: minDate ?? now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: value != null ? TimeOfDay.fromDateTime(value!) : TimeOfDay.now(),
    );
    if (time == null || !context.mounted) return;
    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          controller: TextEditingController(
            text: value != null ? formatter.format(value!) : '',
          ),
          validator: (_) => value == null ? 'Please select a date' : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2 — Tickets
// ---------------------------------------------------------------------------

class _Step2Tickets extends StatelessWidget {
  final EventFormData data;
  const _Step2Tickets({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.ticketTypes.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.confirmation_number_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  const Text('No ticket types added yet'),
                ],
              ),
            ),
          )
        else
          ...data.ticketTypes.asMap().entries.map((e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.confirmation_number_outlined),
                  title: Text(e.value.name),
                  subtitle: Text(e.value.isFree
                      ? 'Free • ${e.value.quantity} seats'
                      : '₹${e.value.price.toStringAsFixed(2)} • ${e.value.quantity} seats'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => context.read<EventFormBloc>().add(
                          EventFormTicketTypeRemoved(index: e.key),
                        ),
                  ),
                ),
              )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showAddTicketSheet(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Ticket Type'),
        ),
      ],
    );
  }

  Future<void> _showAddTicketSheet(BuildContext context) async {
    final bloc = context.read<EventFormBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddTicketSheet(
        onAdd: (ticketType) => bloc.add(
          EventFormTicketTypeAdded(ticketType: ticketType),
        ),
      ),
    );
  }
}

class _AddTicketSheet extends StatefulWidget {
  final void Function(TicketTypeFormData) onAdd;
  const _AddTicketSheet({required this.onAdd});

  @override
  State<_AddTicketSheet> createState() => _AddTicketSheetState();
}

class _AddTicketSheetState extends State<_AddTicketSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _qtyController = TextEditingController(text: '100');
  final _maxController = TextEditingController(text: '10');
  TicketTier _tier = TicketTier.standard;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Ticket Type',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name *', border: OutlineInputBorder()),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<TicketTier>(
              value: _tier,
              decoration: const InputDecoration(
                  labelText: 'Tier', border: OutlineInputBorder()),
              items: TicketTier.values
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (t) => setState(() => _tier = t ?? TicketTier.standard),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Price (\$)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Quantity', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Max/order', border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.onAdd(TicketTypeFormData(
                    name: _nameController.text.trim(),
                    tier: _tier,
                    price: double.tryParse(_priceController.text) ?? 0,
                    quantity: int.tryParse(_qtyController.text) ?? 100,
                    maxPerOrder: int.tryParse(_maxController.text) ?? 10,
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Ticket Type'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared step widgets
// ---------------------------------------------------------------------------

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Date & Venue', 'Tickets'];
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            return Expanded(
              child: Divider(
                thickness: 2,
                color: stepIndex < currentStep
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            );
          }
          final stepIndex = i ~/ 2;
          final isActive = stepIndex == currentStep;
          final isDone = stepIndex < currentStep;
          return Column(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDone || isActive
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isActive
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentStep;
  final bool isSubmitting;
  final bool canNext;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNavBar({
    required this.currentStep,
    required this.isSubmitting,
    required this.canNext,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  child: const Text('Back'),
                ),
              ),
            if (currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: (!isSubmitting && canNext) ? onNext : null,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(currentStep == 2 ? 'Create Event' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
