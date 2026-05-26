import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vibyuk/core/navigation/route_names.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/creator/domain/entities/creator_profile_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/creator_profile/creator_profile_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/onboarding_progress_bar.dart';

class CreatorOnboardingScreen extends StatefulWidget {
  const CreatorOnboardingScreen({super.key});

  @override
  State<CreatorOnboardingScreen> createState() =>
      _CreatorOnboardingScreenState();
}

class _CreatorOnboardingScreenState extends State<CreatorOnboardingScreen> {
  final _pageController = PageController();

  // Step 1 controllers
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _selectedLanguages = <String>[];

  OnboardingStep _currentStep = OnboardingStep.basicInfo;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _websiteCtrl.dispose();
    _langCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    final nextIdx = OnboardingStep.values.indexOf(_currentStep) + 1;
    if (nextIdx >= OnboardingStep.values.length - 1) {
      context
          .read<CreatorProfileBloc>()
          .add(const CompleteOnboardingStepEvent(step: OnboardingStep.done));
      context.go(RouteNames.creatorDashboard);
      return;
    }
    final next = OnboardingStep.values[nextIdx];
    setState(() => _currentStep = next);
    _pageController.animateToPage(
      nextIdx,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<CreatorProfileBloc, CreatorProfileState>(
        listener: (context, state) {
          if (state is CreatorProfileLoadedState && state.updateSuccess) {
            _nextStep();
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: OnboardingProgressBar(currentStep: _currentStep),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _BasicInfoStep(
                    nameCtrl: _nameCtrl,
                    bioCtrl: _bioCtrl,
                    locationCtrl: _locationCtrl,
                    websiteCtrl: _websiteCtrl,
                    langCtrl: _langCtrl,
                    selectedLanguages: _selectedLanguages,
                    formKey: _formKey,
                    onLanguageAdd: (lang) {
                      final trimmed = lang.trim();
                      if (trimmed.isNotEmpty &&
                          !_selectedLanguages.contains(trimmed)) {
                        setState(() {
                          _selectedLanguages.add(trimmed);
                          _langCtrl.clear();
                        });
                      }
                    },
                    onLanguageRemove: (lang) =>
                        setState(() => _selectedLanguages.remove(lang)),
                    onNext: () {
                      if (_formKey.currentState!.validate()) {
                        context.read<CreatorProfileBloc>().add(
                              UpdateCreatorProfileEvent(
                                displayName: _nameCtrl.text.trim(),
                                bio: _bioCtrl.text.trim().isEmpty
                                    ? null
                                    : _bioCtrl.text.trim(),
                                location: _locationCtrl.text.trim().isEmpty
                                    ? null
                                    : _locationCtrl.text.trim(),
                                website: _websiteCtrl.text.trim().isEmpty
                                    ? null
                                    : _websiteCtrl.text.trim(),
                                languagesSpoken: _selectedLanguages.isNotEmpty
                                    ? List.unmodifiable(_selectedLanguages)
                                    : null,
                              ),
                            );
                      }
                    },
                  ),
                  _SkipStep(
                    title: 'Add your portfolio',
                    description:
                        'Upload photos and videos of your work to showcase your skills.',
                    icon: Icons.photo_library_outlined,
                    actionLabel: 'Add portfolio items',
                    onAction: () => context.push(RouteNames.creatorPortfolio),
                    onSkip: () {
                      context.read<CreatorProfileBloc>().add(
                            const CompleteOnboardingStepEvent(
                                step: OnboardingStep.portfolio),
                          );
                      _nextStep();
                    },
                  ),
                  _SkipStep(
                    title: 'Set your pricing',
                    description:
                        'Create packages so businesses know exactly what they are paying for.',
                    icon: Icons.sell_outlined,
                    actionLabel: 'Set up packages',
                    onAction: () => context.push(RouteNames.creatorPricing),
                    onSkip: () {
                      context.read<CreatorProfileBloc>().add(
                            const CompleteOnboardingStepEvent(
                                step: OnboardingStep.pricing),
                          );
                      _nextStep();
                    },
                  ),
                  _SkipStep(
                    title: 'Set your availability',
                    description:
                        'Let businesses know when you are available for bookings.',
                    icon: Icons.calendar_month_outlined,
                    actionLabel: 'Set availability',
                    onAction: () => context.push(RouteNames.creatorAvailability),
                    onSkip: () {
                      context.read<CreatorProfileBloc>().add(
                            const CompleteOnboardingStepEvent(
                                step: OnboardingStep.availability),
                          );
                      _nextStep();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicInfoStep extends StatelessWidget {
  const _BasicInfoStep({
    required this.nameCtrl,
    required this.bioCtrl,
    required this.locationCtrl,
    required this.websiteCtrl,
    required this.langCtrl,
    required this.selectedLanguages,
    required this.formKey,
    required this.onLanguageAdd,
    required this.onLanguageRemove,
    required this.onNext,
  });

  final TextEditingController nameCtrl;
  final TextEditingController bioCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController websiteCtrl;
  final TextEditingController langCtrl;
  final List<String> selectedLanguages;
  final GlobalKey<FormState> formKey;
  final ValueChanged<String> onLanguageAdd;
  final ValueChanged<String> onLanguageRemove;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          Text('Tell us about yourself',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          AppTextField(
            controller: nameCtrl,
            label: 'Display Name',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: bioCtrl,
            label: 'Bio',
            maxLines: 3,
            hint: 'Tell brands what makes you unique…',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: locationCtrl,
            label: 'Location',
            hint: 'City, Country',
            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: websiteCtrl,
            label: 'Website',
            hint: 'https://',
            prefixIcon: const Icon(Icons.link_rounded, size: 20),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 20),
          Text('Languages spoken',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: langCtrl,
                  label: 'Add language',
                  hint: 'e.g. Hindi, English',
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: onLanguageAdd,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add_rounded),
                onPressed: () => onLanguageAdd(langCtrl.text),
              ),
            ],
          ),
          if (selectedLanguages.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedLanguages
                  .map((l) => Chip(
                        label: Text(l,
                            style: const TextStyle(fontSize: 13)),
                        deleteIcon:
                            const Icon(Icons.close_rounded, size: 16),
                        onDeleted: () => onLanguageRemove(l),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 32),
          BlocBuilder<CreatorProfileBloc, CreatorProfileState>(
            builder: (context, state) => FilledButton(
              onPressed:
                  state is CreatorProfileUpdatingState ? null : onNext,
              child: state is CreatorProfileUpdatingState
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkipStep extends StatelessWidget {
  const _SkipStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
    required this.onSkip,
  });

  final String title;
  final String description;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(description,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center),
          const Spacer(),
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: Text(actionLabel),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onSkip,
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: const Text('Skip for now'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
