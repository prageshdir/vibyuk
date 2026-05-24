import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerSheet extends StatelessWidget {
  const MediaPickerSheet({
    super.key,
    required this.onImageSelected,
    required this.onFileSelected,
  });

  final void Function(File) onImageSelected;
  final void Function(File) onFileSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Option(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: Colors.purple,
                  onTap: () async {
                    Navigator.pop(context);
                    final xFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery, imageQuality: 85);
                    if (xFile != null) onImageSelected(File(xFile.path));
                  },
                ),
                _Option(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    final xFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera, imageQuality: 85);
                    if (xFile != null) onImageSelected(File(xFile.path));
                  },
                ),
                _Option(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'File',
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.any, allowMultiple: false);
                    final path = result?.files.single.path;
                    if (path != null) onFileSelected(File(path));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
