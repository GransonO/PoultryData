import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../gallery/providers/gallery_provider.dart';
import '../models/capture_mode.dart';
import '../providers/camera_provider.dart';
import '../widgets/capture_guide_overlay.dart';
import '../widgets/capture_mode_selector.dart';
import '../widgets/quality_tips_banner.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraProvider _cameraProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraProvider = CameraProvider();
    _cameraProvider.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraProvider.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _cameraProvider.initialize();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraProvider.dispose();
    super.dispose();
  }

  Future<void> _onCapture() async {
    final auth = context.read<AuthProvider>();
    final gallery = context.read<GalleryProvider>();
    final userName = auth.currentUser?.name ?? 'Unknown';

    if (_cameraProvider.mediaMode == MediaMode.photo) {
      final item = await _cameraProvider.capturePhoto(capturedBy: userName);
      if (item != null && mounted) {
        gallery.addCapture(item);
        _showSnackBar(AppStrings.captureSaved, isSuccess: true);
      }
    } else {
      if (_cameraProvider.isRecording) {
        final item =
            await _cameraProvider.stopVideoRecording(capturedBy: userName);
        if (item != null && mounted) {
          gallery.addCapture(item);
          _showSnackBar(AppStrings.captureSaved, isSuccess: true);
        }
      } else {
        await _cameraProvider.startVideoRecording();
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor:
            isSuccess ? AppColors.guideGood : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _cameraProvider,
      child: Consumer<CameraProvider>(
        builder: (context, cam, _) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Camera preview
                  _buildPreview(cam),

                  // Guide overlay
                  if (cam.isInitialized)
                    CaptureGuideOverlay(
                      captureMode: cam.chickenMode,
                      isRecording: cam.isRecording,
                    ),

                  // Top controls
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildTopBar(cam),
                  ),

                  // Bottom controls
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildBottomControls(cam),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(CameraProvider cam) {
    if (!cam.isInitialized || cam.controller == null) {
      return _buildCameraPlaceholder(cam);
    }
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: cam.controller!.value.previewSize?.height ?? 1,
            height: cam.controller!.value.previewSize?.width ?? 1,
            child: CameraPreview(cam.controller!),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder(CameraProvider cam) {
    return Container(
      color: Colors.black,
      child: Center(
        child: cam.errorMessage != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.no_photography_outlined,
                      color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    cam.errorMessage!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: cam.initialize,
                    child: const Text('Retry'),
                  ),
                ],
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.cameraInitializing,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTopBar(CameraProvider cam) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Back
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => context.pop(),
          ),

          // Title
          const Expanded(
            child: Text(
              AppStrings.cameraTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Flash toggle
          IconButton(
            icon: Icon(
              cam.flashMode == FlashMode.off
                  ? Icons.flash_off
                  : Icons.flash_on,
              color: cam.flashMode == FlashMode.off
                  ? Colors.white70
                  : AppColors.secondaryLight,
            ),
            onPressed: cam.isInitialized ? cam.toggleFlash : null,
          ),

          // Switch camera
          if (cam.hasMultipleCameras)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: cam.switchCamera,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(CameraProvider cam) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tips banner
          QualityTipsBanner(
            tip: cam.currentTip,
            isRecording: cam.isRecording,
          ),
          const SizedBox(height: 16),

          // Mode selectors
          CaptureModeSelector(
            mediaMode: cam.mediaMode,
            chickenMode: cam.chickenMode,
            onMediaModeChanged: cam.setMediaMode,
            onChickenModeChanged: cam.setChickenMode,
            isRecording: cam.isRecording,
          ),
          const SizedBox(height: 20),

          // Capture row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Gallery shortcut
              GestureDetector(
                onTap: () => context.push('/gallery'),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Icon(Icons.photo_library_outlined,
                      color: Colors.white, size: 26),
                ),
              ),

              // Main capture button
              _CaptureButton(
                mediaMode: cam.mediaMode,
                isRecording: cam.isRecording,
                isCapturing: cam.isCapturing,
                onPressed: cam.isInitialized ? _onCapture : null,
              ),

              // Placeholder for symmetry
              const SizedBox(width: 52),
            ],
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final MediaMode mediaMode;
  final bool isRecording;
  final bool isCapturing;
  final VoidCallback? onPressed;

  const _CaptureButton({
    required this.mediaMode,
    required this.isRecording,
    required this.isCapturing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isVideo = mediaMode == MediaMode.video;
    final innerColor = isRecording
        ? AppColors.recordingRed
        : isVideo
            ? AppColors.recordingRed
            : Colors.white;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: isCapturing
              ? const CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5)
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isRecording ? 28 : 58,
                  height: isRecording ? 28 : 58,
                  decoration: BoxDecoration(
                    color: innerColor,
                    borderRadius: BorderRadius.circular(isRecording ? 6 : 50),
                  ),
                ),
        ),
      ),
    );
  }
}
