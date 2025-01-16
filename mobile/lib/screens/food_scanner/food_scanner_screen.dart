import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nutrigenius/services/ml/food_recognition_service.dart';
import 'package:nutrigenius/screens/food_scanner/food_result_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({Key? key}) : super(key: key);

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  final FoodRecognitionService _foodRecognitionService = FoodRecognitionService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      _showPermissionDeniedDialog();
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      _showError('No cameras available');
      return;
    }

    // Use the first back camera
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'NutriGenius needs camera access to scan food items. '
          'Please grant camera permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isProcessing || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Capture image
      final image = await _controller!.takePicture();
      
      // Initialize ML service if not already done
      await _foodRecognitionService.initialize();
      
      // Process image
      final results = await _foodRecognitionService.recognizeFood(File(image.path));

      if (mounted) {
        if (results['success']) {
          // Navigate to results screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodResultScreen(
                imageFile: File(image.path),
                recognitionResults: results,
              ),
            ),
          );
        } else {
          _showError(results['message']);
        }
      }
    } catch (e) {
      _showError('Error processing image: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              _controller?.setFlashMode(
                _controller!.value.flashMode == FlashMode.off
                    ? FlashMode.torch
                    : FlashMode.off,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Camera preview
                CameraPreview(_controller!),

                // Scanning overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                ),

                // Processing indicator
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),

          // Camera controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () {
                    // TODO: Implement gallery picker
                  },
                ),
                FloatingActionButton(
                  onPressed: _isProcessing ? null : _captureAndAnalyze,
                  child: Icon(_isProcessing ? Icons.hourglass_empty : Icons.camera),
                ),
                IconButton(
                  icon: const Icon(Icons.flip_camera_android),
                  onPressed: () {
                    // TODO: Implement camera switch
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 