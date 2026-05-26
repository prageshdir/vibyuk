import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_profile/creator_profile_bloc.dart';

class EditCreatorProfileScreen extends StatefulWidget {
  const EditCreatorProfileScreen({super.key});

  @override
  State<EditCreatorProfileScreen> createState() =>
      _EditCreatorProfileScreenState();
}

class _EditCreatorProfileScreenState extends State<EditCreatorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _websiteCtrl;
  late List<String> _categories;
  late List<String> _skills;
  late List<String> _languages;

  static const _allCategories = [
    'DJ', 'Photography', 'Videography', 'Music', 'Dance',
    'Comedy', 'Fashion', 'Food', 'Travel', 'Lifestyle',
    'Fitness', 'Gaming', 'Tech', 'Art', 'Education',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<CreatorProfileBloc>().state;
    final profile = state is CreatorProfileLoadedState
        ? state.profile
        : state is CreatorProfileUpdatingState
            ? state.profile
            : null;
    _nameCtrl = TextEditingController(text: profile?.displayName ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _locationCtrl = TextEditingController(text: profile?.location ?? '');
    _websiteCtrl = TextEditingController(text: profile?.website ?? '');
    _categories = List.from(profile?.categories ?? []);
    _skills = List.from(profile?.skills ?? []);
    _languages = List.from(profile?.languagesSpoken ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreatorProfileBloc>().add(
          UpdateCreatorProfileEvent(
            displayName: _nameCtrl.text.trim(),
            bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
            location: _locationCtrl.text.trim().isEmpty
                ? null
                : _locationCtrl.text.trim(),
            website: _websiteCtrl.text.trim().isEmpty
                ? null
                : _websiteCtrl.text.trim(),
            categories: _categories,
            skills: _skills,
            languagesSpoken: _languages,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<CreatorProfileBloc, CreatorProfileState>(
      listener: (context, state) {
        if (state is CreatorProfileLoadedState && state.updateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated')),
          );
          Navigator.of(context).pop();
        }
        if (state is CreatorProfileLoadedState && state.updateError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.updateError!.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
          actions: [
            BlocBuilder<CreatorProfileBloc, CreatorProfileState>(
              builder: (context, state) {
                final saving = state is CreatorProfileUpdatingState;
                return saving
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: _save,
                        child: const Text('Save'),
                      );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Basic Info',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nameCtrl,
                label: 'Display Name *',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _bioCtrl,
                label: 'Bio',
                hint: 'Tell clients about yourself',
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _locationCtrl,
                label: 'Location',
                hint: 'City, State',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _websiteCtrl,
                label: 'Website',
                hint: 'https://yourwebsite.com',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              Text('Categories',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _allCategories
                    .map((cat) => FilterChip(
                          label: Text(cat),
                          selected: _categories.contains(cat),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _categories.add(cat);
                              } else {
                                _categories.remove(cat);
                              }
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              _TagsSection(
                title: 'Skills',
                tags: _skills,
                hint: 'Add a skill (e.g. Lightroom)',
                onChanged: (tags) => setState(() => _skills = tags),
              ),
              const SizedBox(height: 24),
              _TagsSection(
                title: 'Languages Spoken',
                tags: _languages,
                hint: 'Add a language (e.g. Hindi)',
                onChanged: (tags) => setState(() => _languages = tags),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagsSection extends StatefulWidget {
  final String title;
  final List<String> tags;
  final String hint;
  final ValueChanged<List<String>> onChanged;

  const _TagsSection({
    required this.title,
    required this.tags,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<_TagsSection> {
  final _ctrl = TextEditingController();

  void _add() {
    final val = _ctrl.text.trim();
    if (val.isEmpty || widget.tags.contains(val)) return;
    widget.onChanged([...widget.tags, val]);
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title,
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(hintText: widget.hint),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _add,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: widget.tags
              .map((t) => Chip(
                    label: Text(t),
                    onDeleted: () {
                      final updated = List<String>.from(widget.tags)..remove(t);
                      widget.onChanged(updated);
                    },
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ],
    );
  }
}
