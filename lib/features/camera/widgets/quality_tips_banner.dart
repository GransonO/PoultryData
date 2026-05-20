import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QualityTipsBanner extends StatefulWidget {
  final String tip;
  final bool isRecording;

  const QualityTipsBanner({
    super.key,
    required this.tip,
    this.isRecording = false,
  });

  @override
  State<QualityTipsBanner> createState() => _QualityTipsBannerState();
}

class _QualityTipsBannerState extends State<QualityTipsBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  String _displayedTip = '';

  @override
  void initState() {
    super.initState();
    _displayedTip = widget.tip;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..value = 1.0;
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(QualityTipsBanner old) {
    super.didUpdateWidget(old);
    if (old.tip != widget.tip) {
      _animateTipChange();
    }
  }

  Future<void> _animateTipChange() async {
    await _controller.reverse();
    setState(() => _displayedTip = widget.tip);
    await _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isRecording ? AppColors.recordingRed : AppColors.guideTip;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.6), width: 1),
        ),
        child: Row(
          children: [
            Icon(
              widget.isRecording ? Icons.fiber_manual_record : Icons.lightbulb_outline,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.isRecording ? 'Recording in progress…' : _displayedTip,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
