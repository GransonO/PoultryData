import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/capture_item.dart';
import '../providers/gallery_provider.dart';

class CaptureDetailScreen extends StatefulWidget {
  final String captureId;

  const CaptureDetailScreen({super.key, required this.captureId});

  @override
  State<CaptureDetailScreen> createState() => _CaptureDetailScreenState();
}

class _CaptureDetailScreenState extends State<CaptureDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _videoInitialized = false;
  CaptureItem? _item;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadItem());
  }

  void _loadItem() {
    final gallery = context.read<GalleryProvider>();
    final item = gallery.findById(widget.captureId);
    if (item == null) {
      context.pop();
      return;
    }
    setState(() => _item = item);
    if (item.isVideo) _initVideoPlayer(item.filePath);
  }

  Future<void> _initVideoPlayer(String path) async {
    _videoController = VideoPlayerController.file(File(path));
    await _videoController!.initialize();
    setState(() => _videoInitialized = true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayback() {
    if (_videoController == null) return;
    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<GalleryProvider>().removeCapture(widget.captureId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final item = _item!;
    final dateStr =
        DateFormat('EEEE, d MMMM yyyy – HH:mm').format(item.capturedAt);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.captureDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Column(
        children: [
          // Media viewer
          Expanded(child: _buildMediaView(item)),

          // Details panel
          _buildDetailsPanel(item, dateStr),
        ],
      ),
    );
  }

  Widget _buildMediaView(CaptureItem item) {
    final file = File(item.filePath);

    if (!file.existsSync()) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined,
                color: Colors.white38, size: 72),
            SizedBox(height: 12),
            Text('File not found',
                style: TextStyle(color: Colors.white54, fontSize: 14)),
          ],
        ),
      );
    }

    if (item.isPhoto) {
      return InteractiveViewer(
        child: Center(
          child: Image.file(file, fit: BoxFit.contain),
        ),
      );
    }

    // Video player
    if (!_videoInitialized || _videoController == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
        GestureDetector(
          onTap: _togglePlayback,
          child: AnimatedOpacity(
            opacity: _isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
            ),
          ),
        ),
        if (_isPlaying)
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _togglePlayback,
            child: const SizedBox.expand(),
          ),
      ],
    );
  }

  Widget _buildDetailsPanel(CaptureItem item, String dateStr) {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.calendar_today_outlined,
                AppStrings.capturedOn, dateStr),
            const SizedBox(height: 10),
            _detailRow(Icons.category_outlined,
                AppStrings.captureType, item.typeLabel),
            const SizedBox(height: 10),
            _detailRow(Icons.tune_outlined,
                AppStrings.captureMode, item.captureModeLabel),
            const SizedBox(height: 10),
            _detailRow(Icons.person_outline,
                AppStrings.capturedBy, item.capturedBy),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
