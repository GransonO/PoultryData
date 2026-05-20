import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/capture_mode.dart';
import '../../gallery/models/capture_item.dart';

class CaptureModeSelector extends StatelessWidget {
  final MediaMode mediaMode;
  final ChickenCaptureMode chickenMode;
  final ValueChanged<MediaMode> onMediaModeChanged;
  final ValueChanged<ChickenCaptureMode> onChickenModeChanged;
  final bool isRecording;

  const CaptureModeSelector({
    super.key,
    required this.mediaMode,
    required this.chickenMode,
    required this.onMediaModeChanged,
    required this.onChickenModeChanged,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chicken mode toggle (Full Body / Close-up)
        _ChickenModeToggle(
          selected: chickenMode,
          onChanged: isRecording ? null : onChickenModeChanged,
        ),
        const SizedBox(height: 12),
        // Media type toggle (Photo / Video)
        _MediaModeToggle(
          selected: mediaMode,
          onChanged: isRecording ? null : onMediaModeChanged,
        ),
      ],
    );
  }
}

class _MediaModeToggle extends StatelessWidget {
  final MediaMode selected;
  final ValueChanged<MediaMode>? onChanged;

  const _MediaModeToggle({required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: MediaMode.values.map((mode) {
        final isSelected = mode == selected;
        return GestureDetector(
          onTap: () => onChanged?.call(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  mode == MediaMode.photo ? Icons.photo_camera : Icons.videocam,
                  size: 16,
                  color: isSelected ? AppColors.primary : Colors.white70,
                ),
                const SizedBox(width: 6),
                Text(
                  mode.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ChickenModeToggle extends StatelessWidget {
  final ChickenCaptureMode selected;
  final ValueChanged<ChickenCaptureMode>? onChanged;

  const _ChickenModeToggle({required this.selected, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ChickenCaptureMode.values.map((mode) {
          final isSelected = mode == selected;
          return GestureDetector(
            onTap: () => onChanged?.call(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.secondary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${mode.icon}  ${mode.label}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
