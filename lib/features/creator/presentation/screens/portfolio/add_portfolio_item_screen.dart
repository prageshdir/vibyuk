import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibyuk/core/theme/app_colors.dart';
import 'package:vibyuk/core/widgets/inputs/app_text_field.dart';
import 'package:vibyuk/features/creator/domain/entities/portfolio_item_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/portfolio/portfolio_bloc.dart';

class AddPortfolioItemScreen extends StatefulWidget {
  const AddPortfolioItemScreen({super.key});

  @override
  State<AddPortfolioItemScreen> createState() => _AddPortfolioItemScreenState();
}

class _AddPortfolioItemScreenState extends State<AddPortfolioItemScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _pickedFile;
  MediaType _mediaType = MediaType.image;
  bool _isFeatured = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final result = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Photo from gallery'),
              onTap: () async {
                final file =
                    await picker.pickImage(source: ImageSource.gallery);
                if (mounted) Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Video from gallery'),
              onTap: () async {
                final file =
                    await picker.pickVideo(source: ImageSource.gallery);
                if (mounted) Navigator.pop(context, file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () async {
                final file =
                    await picker.pickImage(source: ImageSource.camera);
                if (mounted) Navigator.pop(context, file);
              },
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _pickedFile = result;
        _mediaType = result.mimeType?.startsWith('video') == true
            ? MediaType.video
            : MediaType.image;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    context.read<PortfolioBloc>().add(AddPortfolioItemEvent(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          mediaType: _mediaType,
          filePath: _pickedFile!.path,
          tags: tags,
          isFeatured: _isFeatured,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Portfolio Item',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<PortfolioBloc, PortfolioState>(
        listenWhen: (_, s) => s is PortfolioLoadedState,
        listener: (context, state) {
          if (state is PortfolioLoadedState && state.uploadSuccess) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isUploading =
              state is PortfolioLoadedState && state.isUploading;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Media picker
                GestureDetector(
                  onTap: isUploading ? null : _pickMedia,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: theme.colorScheme.outlineVariant),
                    ),
                    child: _pickedFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_mediaType == MediaType.image)
                                  Image.network(
                                    _pickedFile!.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image, size: 40),
                                  )
                                else
                                  const Icon(Icons.video_file_outlined,
                                      size: 64),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: _pickMedia,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit_rounded,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text('Tap to add photo or video',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _titleCtrl,
                  label: 'Title',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descCtrl,
                  label: 'Description',
                  maxLines: 3,
                  hint: 'Describe this work…',
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _tagsCtrl,
                  label: 'Tags',
                  hint: 'fashion, lifestyle, beauty (comma separated)',
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                  title: const Text('Feature this item'),
                  subtitle: const Text('Featured items appear first'),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: isUploading ? null : _submit,
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  child: isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Upload Item'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
