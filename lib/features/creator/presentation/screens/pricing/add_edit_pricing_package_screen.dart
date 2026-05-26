import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/creator/domain/entities/pricing_package_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/pricing/pricing_bloc.dart';

class AddEditPricingPackageScreen extends StatefulWidget {
  const AddEditPricingPackageScreen({super.key, this.existingPackage});

  final PricingPackageEntity? existingPackage;

  @override
  State<AddEditPricingPackageScreen> createState() =>
      _AddEditPricingPackageScreenState();
}

class _AddEditPricingPackageScreenState
    extends State<AddEditPricingPackageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _revisionsCtrl = TextEditingController();
  final _inclusionCtrl = TextEditingController();

  PackageType _packageType = PackageType.basic;
  String _currency = 'INR';
  bool _isActive = true;
  List<String> _inclusions = [];

  bool get _isEditing => widget.existingPackage != null;

  @override
  void initState() {
    super.initState();
    final pkg = widget.existingPackage;
    if (pkg != null) {
      _titleCtrl.text = pkg.title;
      _descCtrl.text = pkg.description;
      _priceCtrl.text = pkg.price.toStringAsFixed(0);
      _daysCtrl.text = pkg.deliveryDays.toString();
      _revisionsCtrl.text = pkg.revisions.toString();
      _packageType = pkg.packageType;
      _currency = pkg.currency;
      _isActive = pkg.isActive;
      _inclusions = List.from(pkg.inclusions);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _daysCtrl.dispose();
    _revisionsCtrl.dispose();
    _inclusionCtrl.dispose();
    super.dispose();
  }

  void _addInclusion() {
    final val = _inclusionCtrl.text.trim();
    if (val.isNotEmpty) {
      setState(() {
        _inclusions.add(val);
        _inclusionCtrl.clear();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    final days = int.tryParse(_daysCtrl.text) ?? 1;
    final revisions = int.tryParse(_revisionsCtrl.text) ?? 1;

    if (_isEditing) {
      context.read<PricingBloc>().add(UpdatePricingPackageEvent(
            packageId: widget.existingPackage!.id,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            price: price,
            currency: _currency,
            deliveryDays: days,
            inclusions: _inclusions,
            revisions: revisions,
            isActive: _isActive,
          ));
    } else {
      context.read<PricingBloc>().add(CreatePricingPackageEvent(
            packageType: _packageType,
            title: _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            price: price,
            currency: _currency,
            deliveryDays: days,
            inclusions: _inclusions,
            revisions: revisions,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Package' : 'Create Package',
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<PricingBloc, PricingState>(
        listenWhen: (_, s) => s is PricingLoadedState,
        listener: (context, state) {
          if (state is PricingLoadedState && state.saveSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isSaving =
              state is PricingLoadedState && state.isSaving;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Package type selector (only for new)
                if (!_isEditing) ...[
                  Text('Package Type',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<PackageType>(
                    segments: const [
                      ButtonSegment(
                          value: PackageType.basic,
                          label: Text('Basic'),
                          icon: Icon(Icons.star_border_rounded)),
                      ButtonSegment(
                          value: PackageType.standard,
                          label: Text('Standard'),
                          icon: Icon(Icons.star_half_rounded)),
                      ButtonSegment(
                          value: PackageType.premium,
                          label: Text('Premium'),
                          icon: Icon(Icons.star_rounded)),
                    ],
                    selected: {_packageType},
                    onSelectionChanged: (s) =>
                        setState(() => _packageType = s.first),
                  ),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Package Title',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  maxLines: 3,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _priceCtrl,
                        label: 'Price',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        prefixIcon: const Icon(
                            Icons.currency_rupee_rounded,
                            size: 18),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _daysCtrl,
                        label: 'Delivery Days',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        controller: _revisionsCtrl,
                        label: 'Revisions',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Inclusions
                Text('What\'s included',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _inclusionCtrl,
                        label: 'Add inclusion',
                        hint: 'e.g. 3 posts, 1 reel',
                        onSubmitted: (_) => _addInclusion(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _addInclusion,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (_inclusions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _inclusions
                        .map((inc) => Chip(
                              label: Text(inc),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setState(
                                  () => _inclusions.remove(inc)),
                            ))
                        .toList(),
                  ),
                ],
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    title: const Text('Active'),
                    subtitle: const Text('Inactive packages are hidden'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isEditing ? 'Save Changes' : 'Create Package'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
