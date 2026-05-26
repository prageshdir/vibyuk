import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/utils/validators/form_validators.dart';
import 'package:vibyuk/core/widgets/buttons/primary_button.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/profile/domain/entities/profile_entity.dart';
import 'package:vibyuk/features/profile/domain/usecases/update_profile_use_case.dart';
import 'package:vibyuk/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:vibyuk/features/profile/presentation/widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _websiteController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _tiktokController;
  late TextEditingController _companyController;
  late TextEditingController _industryController;

  ProfileEntity? _profile;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _bioController = TextEditingController();
    _locationController = TextEditingController();
    _websiteController = TextEditingController();
    _instagramController = TextEditingController();
    _twitterController = TextEditingController();
    _tiktokController = TextEditingController();
    _companyController = TextEditingController();
    _industryController = TextEditingController();
  }

  void _populateFields(ProfileEntity profile) {
    if (_profile == null) {
      _profile = profile;
      _firstNameController.text = profile.user.firstName;
      _lastNameController.text = profile.user.lastName ?? '';
      _bioController.text = profile.bio ?? '';
      _locationController.text = profile.location ?? '';
      _websiteController.text = profile.website ?? '';
      _instagramController.text = profile.socialLinks.instagram ?? '';
      _twitterController.text = profile.socialLinks.twitter ?? '';
      _tiktokController.text = profile.socialLinks.tiktok ?? '';
      _companyController.text = profile.businessInfo?.companyName ?? '';
      _industryController.text = profile.businessInfo?.industry ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _tiktokController.dispose();
    _companyController.dispose();
    _industryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    context.read<ProfileBloc>().add(UploadAvatarEvent(filePath: image.path));
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileBloc>().add(
          UpdateProfileEvent(
            params: UpdateProfileParams(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
              location: _locationController.text.trim().isEmpty
                  ? null
                  : _locationController.text.trim(),
              website: _websiteController.text.trim().isEmpty
                  ? null
                  : _websiteController.text.trim(),
              instagram: _instagramController.text.trim().isEmpty
                  ? null
                  : _instagramController.text.trim(),
              twitter: _twitterController.text.trim().isEmpty
                  ? null
                  : _twitterController.text.trim(),
              tiktok: _tiktokController.text.trim().isEmpty
                  ? null
                  : _tiktokController.text.trim(),
              companyName: _companyController.text.trim().isEmpty
                  ? null
                  : _companyController.text.trim(),
              industry: _industryController.text.trim().isEmpty
                  ? null
                  : _industryController.text.trim(),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        switch (state) {
          case ProfileUpdatedState():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.pop();
          case ProfileErrorState(:final failure):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          default:
            break;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          centerTitle: true,
          actions: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final isLoading = state is ProfileUpdatingState || state is AvatarUploadingState;
                return TextButton(
                  onPressed: isLoading ? null : _onSave,
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final profile = switch (state) {
              ProfileLoadedState(:final profile) => profile,
              ProfileUpdatingState(:final currentProfile) => currentProfile,
              ProfileUpdatedState(:final profile) => profile,
              AvatarUploadingState(:final currentProfile) => currentProfile,
              ProfileErrorState(:final currentProfile) => currentProfile,
              _ => null,
            };

            if (profile != null) _populateFields(profile);

            final isUploading = state is AvatarUploadingState;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Center(
                      child: ProfileAvatar(
                        avatarUrl: profile?.user.avatarUrl,
                        displayName: profile?.user.fullName ?? 'U',
                        radius: 56,
                        showEditOverlay: true,
                        isUploading: isUploading,
                        onTap: isUploading ? null : _pickImage,
                      ),
                    ),
                    if (isUploading) ...[
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Uploading photo…',
                          style: TextStyle(color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    _SectionLabel('Basic Info'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _firstNameController,
                            label: 'First name',
                            textInputAction: TextInputAction.next,
                            validator: (v) => FormValidators.required(v, fieldName: 'First name'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _lastNameController,
                            label: 'Last name',
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hint: 'Tell people about yourself…',
                      maxLines: 4,
                      maxLength: 300,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'London, UK',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _websiteController,
                      label: 'Website',
                      hint: 'https://yoursite.com',
                      keyboardType: TextInputType.url,
                      prefixIcon: const Icon(Icons.link_rounded),
                      textInputAction: TextInputAction.next,
                      validator: FormValidators.url,
                    ),

                    const SizedBox(height: 32),
                    _SectionLabel('Social Links'),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _instagramController,
                      label: 'Instagram',
                      hint: 'username',
                      prefixIcon: const Icon(Icons.camera_alt_outlined),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _twitterController,
                      label: 'X / Twitter',
                      hint: 'username',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _tiktokController,
                      label: 'TikTok',
                      hint: 'username',
                      prefixIcon: const Icon(Icons.music_note_rounded),
                      textInputAction: TextInputAction.done,
                    ),

                    if (profile?.isBusiness == true) ...[
                      const SizedBox(height: 32),
                      _SectionLabel('Company Info'),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _companyController,
                        label: 'Company name',
                        prefixIcon: const Icon(Icons.business_rounded),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _industryController,
                        label: 'Industry',
                        prefixIcon: const Icon(Icons.category_outlined),
                        textInputAction: TextInputAction.done,
                      ),
                    ],

                    const SizedBox(height: 40),
                    PrimaryButton(
                      label: 'Save Changes',
                      onPressed: state is ProfileUpdatingState ? null : _onSave,
                      isLoading: state is ProfileUpdatingState,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
