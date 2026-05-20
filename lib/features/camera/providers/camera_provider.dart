import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../gallery/models/capture_item.dart';
import '../models/capture_mode.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  MediaMode _mediaMode = MediaMode.photo;
  ChickenCaptureMode _chickenMode = ChickenCaptureMode.fullBody;

  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isCapturing = false;
  String? _errorMessage;

  int _currentTipIndex = 0;
  Timer? _tipTimer;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  bool get isCapturing => _isCapturing;
  String? get errorMessage => _errorMessage;
  MediaMode get mediaMode => _mediaMode;
  ChickenCaptureMode get chickenMode => _chickenMode;
  bool get hasMultipleCameras => _cameras.length > 1;

  String get currentTip {
    final tips = _chickenMode.tips;
    return tips[_currentTipIndex % tips.length];
  }

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _errorMessage = 'No cameras found on this device';
        notifyListeners();
        return;
      }
      await _initController(_cameras[_selectedCameraIndex]);
    } on CameraException catch (e) {
      _errorMessage = e.description ?? 'Camera error';
      notifyListeners();
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    await _controller?.dispose();

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      _isInitialized = true;
      _errorMessage = null;
      _startTipRotation();
      notifyListeners();
    } on CameraException catch (e) {
      _errorMessage = e.description ?? 'Failed to initialize camera';
      _isInitialized = false;
      notifyListeners();
    }
  }

  void _startTipRotation() {
    _tipTimer?.cancel();
    _tipTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _currentTipIndex++;
      notifyListeners();
    });
  }

  void setMediaMode(MediaMode mode) {
    if (_isRecording) return;
    _mediaMode = mode;
    notifyListeners();
  }

  void setChickenMode(ChickenCaptureMode mode) {
    _chickenMode = mode;
    _currentTipIndex = 0;
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _isInitialized = false;
    notifyListeners();
    await _initController(_cameras[_selectedCameraIndex]);
  }

  Future<CaptureItem?> capturePhoto({required String capturedBy}) async {
    if (!_isInitialized || _controller == null || _isCapturing) return null;

    _isCapturing = true;
    notifyListeners();

    try {
      final xFile = await _controller!.takePicture();
      final id = const Uuid().v4();

      final item = CaptureItem(
        id: id,
        filePath: xFile.path,
        type: CaptureType.photo,
        captureMode: _chickenMode,
        capturedAt: DateTime.now(),
        capturedBy: capturedBy,
      );

      _isCapturing = false;
      notifyListeners();
      return item;
    } on CameraException catch (e) {
      _errorMessage = e.description ?? 'Failed to capture photo';
      _isCapturing = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    if (!_isInitialized || _controller == null || _isRecording) return;

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      notifyListeners();
    } on CameraException catch (e) {
      _errorMessage = e.description ?? 'Failed to start recording';
      notifyListeners();
    }
  }

  Future<CaptureItem?> stopVideoRecording({required String capturedBy}) async {
    if (!_isRecording || _controller == null) return null;

    try {
      final xFile = await _controller!.stopVideoRecording();
      _isRecording = false;

      final id = const Uuid().v4();
      final item = CaptureItem(
        id: id,
        filePath: xFile.path,
        type: CaptureType.video,
        captureMode: _chickenMode,
        capturedAt: DateTime.now(),
        capturedBy: capturedBy,
      );

      notifyListeners();
      return item;
    } on CameraException catch (e) {
      _errorMessage = e.description ?? 'Failed to stop recording';
      _isRecording = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_isInitialized) return;
    final current = _controller!.value.flashMode;
    final next = current == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _controller!.setFlashMode(next);
    notifyListeners();
  }

  FlashMode get flashMode =>
      _controller?.value.flashMode ?? FlashMode.off;

  @override
  void dispose() {
    _tipTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
