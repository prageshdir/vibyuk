import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibyuk/core/widgets/loaders/app_loader.dart';
import 'package:vibyuk/features/creator/domain/entities/kyc_entity.dart';
import 'package:vibyuk/features/creator/presentation/blocs/kyc/kyc_bloc.dart';
import 'package:vibyuk/features/creator/presentation/widgets/kyc_upload_tile.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  KycDocumentType _docType = KycDocumentType.aadhaarCard;
  String? _frontPath;
  String? _backPath;
  String? _selfiePath;

  bool get _backRequired => _docType.requiresBackSide;

  bool get _canSubmit {
    if (_frontPath == null || _selfiePath == null) return false;
    if (_backRequired && _backPath == null) return false;
    return true;
  }

  Future<String?> _pickImage(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source);
    return file?.path;
  }

  Future<void> _pickDocument({required bool isBack}) async {
    final path = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final p = await _pickImage(ImageSource.gallery);
                if (mounted) Navigator.pop(context, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () async {
                final p = await _pickImage(ImageSource.camera);
                if (mounted) Navigator.pop(context, p);
              },
            ),
          ],
        ),
      ),
    );
    if (path != null) {
      setState(() {
        if (isBack) {
          _backPath = path;
        } else {
          _frontPath = path;
        }
      });
    }
  }

  Future<void> _pickSelfie() async {
    final path = await showModalBottomSheet<String?>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a selfie'),
              onTap: () async {
                final p = await _pickImage(ImageSource.camera);
                if (mounted) Navigator.pop(context, p);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final p = await _pickImage(ImageSource.gallery);
                if (mounted) Navigator.pop(context, p);
              },
            ),
          ],
        ),
      ),
    );
    if (path != null) setState(() => _selfiePath = path);
  }

  void _submit() {
    context.read<KycBloc>().add(SubmitKycEvent(
          documentType: _docType,
          documentFrontPath: _frontPath!,
          documentBackPath: _backPath,
          selfiePath: _selfiePath!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<KycBloc, KycState>(
        listener: (context, state) {
          if (state is KycLoadedState) {
            if (state.submitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Documents submitted for review!')),
              );
            } else if (state.submitError != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.submitError!.message)),
              );
            }
          }
        },
        builder: (context, state) => switch (state) {
          KycLoadingState() => const Center(child: AppLoader()),
          KycLoadedState(:final kyc, :final isSubmitting) => _buildContent(
              context, theme, kyc, isSubmitting),
          KycErrorState(:final failure) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(failure.message),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context
                        .read<KycBloc>()
                        .add(const LoadKycStatusEvent()),
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

  Widget _buildContent(
      BuildContext context, ThemeData theme, KycEntity kyc, bool isSubmitting) {
    if (kyc.isApproved) {
      return _StatusBanner(
        icon: Icons.verified_user_rounded,
        iconColor: Colors.green,
        title: 'Identity Verified',
        subtitle: 'Your identity has been successfully verified.',
        backgroundColor: Colors.green.withOpacity(0.08),
      );
    }

    if (kyc.status == KycVerificationStatus.pendingReview) {
      return _StatusBanner(
        icon: Icons.hourglass_bottom_rounded,
        iconColor: Colors.orange,
        title: 'Under Review',
        subtitle:
            'Your documents are being reviewed. This usually takes 1–2 business days.',
        backgroundColor: Colors.orange.withOpacity(0.08),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (kyc.needsResubmission && kyc.rejectionReason != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.error.withOpacity(0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: theme.colorScheme.error, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Resubmission Required',
                          style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.error)),
                      const SizedBox(height: 4),
                      Text(kyc.rejectionReason!,
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),

        Text('Document Type',
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<KycDocumentType>(
          value: _docType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: KycDocumentType.values
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t.label),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() {
              _docType = v;
              _backPath = null;
            });
          },
        ),
        const SizedBox(height: 24),

        Text('Upload Documents',
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        KycUploadTile(
          label: 'Front of Document',
          subtitle: 'Clear photo of the front side',
          icon: Icons.credit_card_outlined,
          filePath: _frontPath,
          previewUrl: kyc.documentFrontUrl,
          onTap: () => _pickDocument(isBack: false),
        ),
        const SizedBox(height: 12),

        if (_backRequired)
          KycUploadTile(
            label: 'Back of Document',
            subtitle: 'Clear photo of the back side',
            icon: Icons.credit_card_outlined,
            filePath: _backPath,
            previewUrl: kyc.documentBackUrl,
            onTap: () => _pickDocument(isBack: true),
          ),
        if (_backRequired) const SizedBox(height: 12),

        KycUploadTile(
          label: 'Selfie',
          subtitle: 'Photo of yourself holding the document',
          icon: Icons.face_outlined,
          filePath: _selfiePath,
          previewUrl: kyc.selfieUrl,
          onTap: _pickSelfie,
        ),
        const SizedBox(height: 12),

        Text(
          'All documents must be clear, unobstructed, and show all corners of the document.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 32),

        FilledButton(
          onPressed: (_canSubmit && !isSubmitting) ? _submit : null,
          style:
              FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Submit for Verification'),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
