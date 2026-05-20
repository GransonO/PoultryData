import '../../gallery/models/capture_item.dart';

enum MediaMode { photo, video }

extension MediaModeLabel on MediaMode {
  String get label => this == MediaMode.photo ? 'Photo' : 'Video';
}

extension ChickenCaptureModeLabel on ChickenCaptureMode {
  String get label => this == ChickenCaptureMode.fullBody ? 'Full Body' : 'Close-up';

  String get icon => this == ChickenCaptureMode.fullBody ? '🐔' : '🔍';

  List<String> get tips {
    if (this == ChickenCaptureMode.fullBody) {
      return [
        'Ensure the entire chicken is within the frame',
        'Both feet and tail should be visible',
        'Keep at least 0.5 m distance for full body',
        'Avoid cutting off wings or tail feathers',
        'Position the chicken against a plain background',
        'Ensure even lighting across the whole body',
      ];
    } else {
      return [
        'Focus on the head and facial features',
        'Comb, beak, and eyes must be clearly visible',
        'Move closer for sharp facial detail',
        'Avoid harsh shadows on the face',
        'Keep the chicken\'s head steady and centred',
        'Wattles and earlobes should be fully visible',
      ];
    }
  }
}
