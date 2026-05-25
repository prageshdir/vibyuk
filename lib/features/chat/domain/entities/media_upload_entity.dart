import 'package:equatable/equatable.dart';

class MediaUploadEntity extends Equatable {
  const MediaUploadEntity({
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

  @override
  List<Object?> get props =>
      [url, mimeType, fileSize, fileName, durationSeconds, width, height];
}
