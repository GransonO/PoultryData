import 'package:flutter/material.dart';
import '../../gallery/models/capture_item.dart';
import '../../../core/constants/app_colors.dart';

class CaptureGuideOverlay extends StatefulWidget {
  final ChickenCaptureMode captureMode;
  final bool isRecording;

  const CaptureGuideOverlay({
    super.key,
    required this.captureMode,
    this.isRecording = false,
  });

  @override
  State<CaptureGuideOverlay> createState() => _CaptureGuideOverlayState();
}

class _CaptureGuideOverlayState extends State<CaptureGuideOverlay>
    with RepaintBoundary, SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final Rect guideRect;
        if (widget.captureMode == ChickenCaptureMode.fullBody) {
          // Full body: wide, tall rect covering most of the frame
          final gw = w * 0.82;
          final gh = h * 0.72;
          guideRect = Rect.fromLTWH(
            (w - gw) / 2,
            h * 0.08,
            gw,
            gh,
          );
        } else {
          // Close-up: smaller, squarish rect in upper-center
          final gw = w * 0.68;
          final gh = h * 0.50;
          guideRect = Rect.fromLTWH(
            (w - gw) / 2,
            h * 0.10,
            gw,
            gh,
          );
        }

        return AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) {
            return CustomPaint(
              painter: _GuideOverlayPainter(
                guideRect: guideRect,
                captureMode: widget.captureMode,
                isRecording: widget.isRecording,
                pulse: _pulseAnim.value,
              ),
              child: _buildLabels(context, guideRect, w, h),
            );
          },
        );
      },
    );
  }

  Widget _buildLabels(
      BuildContext context, Rect guideRect, double w, double h) {
    final isFullBody = widget.captureMode == ChickenCaptureMode.fullBody;

    return Stack(
      children: [
        // Top label
        Positioned(
          top: guideRect.top - 36,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFullBody ? 'Full Body Frame' : 'Close-up Frame',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),

        // Center hint text
        Positioned(
          top: guideRect.top + guideRect.height * 0.38,
          left: guideRect.left,
          width: guideRect.width,
          child: Center(
            child: Text(
              isFullBody ? 'Fit entire chicken here' : 'Position head & face here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Recording indicator
        if (widget.isRecording)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.recordingRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record,
                        color: Colors.white, size: 10),
                    SizedBox(width: 6),
                    Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GuideOverlayPainter extends CustomPainter {
  final Rect guideRect;
  final ChickenCaptureMode captureMode;
  final bool isRecording;
  final double pulse;

  _GuideOverlayPainter({
    required this.guideRect,
    required this.captureMode,
    required this.isRecording,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dim overlay outside guide rect
    final overlayPaint = Paint()..color = AppColors.guideOverlay;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(guideRect, const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // Guide border
    final borderColor = isRecording ? AppColors.recordingRed : AppColors.guideGood;
    final borderPaint = Paint()
      ..color = borderColor.withOpacity(pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(guideRect, const Radius.circular(8)),
      borderPaint,
    );

    // Corner brackets
    _drawCornerBrackets(canvas, guideRect, borderColor);

    // Rule-of-thirds grid (subtle)
    _drawRuleOfThirds(canvas, guideRect);
  }

  void _drawCornerBrackets(Canvas canvas, Rect rect, Color color) {
    const length = 24.0;
    const thickness = 3.5;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final corners = [
      // Top-left
      [rect.topLeft, Offset(rect.left + length, rect.top),
          Offset(rect.left, rect.top + length)],
      // Top-right
      [rect.topRight, Offset(rect.right - length, rect.top),
          Offset(rect.right, rect.top + length)],
      // Bottom-left
      [rect.bottomLeft, Offset(rect.left + length, rect.bottom),
          Offset(rect.left, rect.bottom - length)],
      // Bottom-right
      [rect.bottomRight, Offset(rect.right - length, rect.bottom),
          Offset(rect.right, rect.bottom - length)],
    ];

    for (final corner in corners) {
      final origin = corner[0] as Offset;
      final h = corner[1] as Offset;
      final v = corner[2] as Offset;
      canvas.drawLine(origin, h, paint);
      canvas.drawLine(origin, v, paint);
    }
  }

  void _drawRuleOfThirds(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final thirdW = rect.width / 3;
    final thirdH = rect.height / 3;

    // Vertical lines
    for (int i = 1; i <= 2; i++) {
      canvas.drawLine(
        Offset(rect.left + thirdW * i, rect.top),
        Offset(rect.left + thirdW * i, rect.bottom),
        paint,
      );
    }
    // Horizontal lines
    for (int i = 1; i <= 2; i++) {
      canvas.drawLine(
        Offset(rect.left, rect.top + thirdH * i),
        Offset(rect.right, rect.top + thirdH * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GuideOverlayPainter old) =>
      old.guideRect != guideRect ||
      old.isRecording != isRecording ||
      old.pulse != pulse ||
      old.captureMode != captureMode;
}
