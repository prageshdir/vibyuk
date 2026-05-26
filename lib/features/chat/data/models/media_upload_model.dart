import 'package:vibyuk/features/chat/domain/entities/media_upload_entity.dart';

class MediaUploadModel {
  const MediaUploadModel({
    required this.url,
    this.mimeType,
    this.fileSize,
    this.fileName,
    this.durationSeconds,
    this.width,
    this.height,
  });

  final String url;
  final String? mimeType;
  final int? fileSize;
  final String? fileName;
  final int? durationSeconds;
  final int? width;
  final int? height;

  factory MediaUploadModel.fromJson(Map<String, dynamic> j) => MediaUploadModel(
        url: j['url'] as String,
        mimeType: j['mime_type'] as String?,
        fileSize: j['file_size'] as int?,
        fileName: j['file_name'] as String?,
        durationSeconds: j['duration_seconds'] as int?,
        width: j['width'] as int?,
        height: j['height'] as int?,
      );

  MediaUploadEntity toEntity() => MediaUploadEntity(
        url: url,
        mimeType: mimeType,
        fileSize: fileSize,
        fileName: fileName,
        durationSeconds: durationSeconds,
        width: width,
        height: height,
      );
}
