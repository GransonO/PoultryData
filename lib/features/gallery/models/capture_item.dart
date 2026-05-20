import 'package:flutter/foundation.dart';

enum CaptureType { photo, video }

enum ChickenCaptureMode { fullBody, closeUp }

@immutable
class CaptureItem {
  final String id;
  final String filePath;
  final CaptureType type;
  final ChickenCaptureMode captureMode;
  final DateTime capturedAt;
  final String capturedBy;
  final Duration? videoDuration;

  const CaptureItem({
    required this.id,
    required this.filePath,
    required this.type,
    required this.captureMode,
    required this.capturedAt,
    required this.capturedBy,
    this.videoDuration,
  });

  bool get isPhoto => type == CaptureType.photo;
  bool get isVideo => type == CaptureType.video;

  String get typeLabel => type == CaptureType.photo ? 'Photo' : 'Video';

  String get captureModeLabel =>
      captureMode == ChickenCaptureMode.fullBody ? 'Full Body' : 'Close-up';

  CaptureItem copyWith({
    String? id,
    String? filePath,
    CaptureType? type,
    ChickenCaptureMode? captureMode,
    DateTime? capturedAt,
    String? capturedBy,
    Duration? videoDuration,
  }) {
    return CaptureItem(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      captureMode: captureMode ?? this.captureMode,
      capturedAt: capturedAt ?? this.capturedAt,
      capturedBy: capturedBy ?? this.capturedBy,
      videoDuration: videoDuration ?? this.videoDuration,
    );
  }
}
