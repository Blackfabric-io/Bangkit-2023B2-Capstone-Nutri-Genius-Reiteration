import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FoodRecognitionService {
  static const String _modelPath = 'assets/ml_models/food_recognition_model.tflite';
  static const String _labelsPath = 'assets/ml_models/food_labels.txt';
  
  late final Interpreter _interpreter;
  late final List<String> _labels;
  bool _isInitialized = false;

  // Singleton pattern
  static final FoodRecognitionService _instance = FoodRecognitionService._internal();
  factory FoodRecognitionService() => _instance;
  FoodRecognitionService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TFLite model
      final interpreterOptions = InterpreterOptions()
        ..addDelegate(GpuDelegateV2())  // Use GPU acceleration if available
        ..threads = 4;  // Use multiple threads for CPU
      
      _interpreter = await Interpreter.fromAsset(
        _modelPath,
        options: interpreterOptions,
      );

      // Load labels
      final labelsData = await rootBundle.loadString(_labelsPath);
      _labels = labelsData.split('\n')
          .where((label) => label.isNotEmpty)
          .toList();

      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize food recognition: $e');
    }
  }

  Future<Map<String, dynamic>> recognizeFood(File imageFile) async {
    if (!_isInitialized) {
      throw Exception('Food recognition service not initialized');
    }

    try {
      // Read and preprocess the image
      final image = await _preprocessImage(imageFile);

      // Allocate tensors for input and output
      final inputShape = _interpreter.getInputTensor(0).shape;
      final outputShape = _interpreter.getOutputTensor(0).shape;
      
      final inputTensor = List.generate(
        inputShape[0],
        (index) => List.generate(
          inputShape[1],
          (index) => List.generate(
            inputShape[2],
            (index) => List<double>.filled(inputShape[3], 0),
          ),
        ),
      );

      final outputTensor = List<double>.filled(outputShape[1], 0);

      // Copy image data to input tensor
      for (var y = 0; y < image.height; y++) {
        for (var x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          inputTensor[0][y][x][0] = (pixel.r / 255.0) - 0.5;
          inputTensor[0][y][x][1] = (pixel.g / 255.0) - 0.5;
          inputTensor[0][y][x][2] = (pixel.b / 255.0) - 0.5;
        }
      }

      // Run inference
      _interpreter.run(inputTensor, outputTensor);

      // Process results
      final results = <String, double>{};
      for (var i = 0; i < outputTensor.length; i++) {
        if (outputTensor[i] > 0.1) { // Confidence threshold
          results[_labels[i]] = outputTensor[i];
        }
      }

      // Sort results by confidence
      final sortedResults = Map.fromEntries(
        results.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value))
      );

      if (sortedResults.isEmpty) {
        return {
          'success': false,
          'message': 'No food items recognized with sufficient confidence',
        };
      }

      return {
        'success': true,
        'results': sortedResults,
        'topResult': {
          'label': sortedResults.entries.first.key,
          'confidence': sortedResults.entries.first.value,
        },
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error processing image: $e',
      };
    }
  }

  Future<img.Image> _preprocessImage(File imageFile) async {
    // Read image file
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes)!;

    // Resize image to model input size (e.g., 224x224)
    image = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    return image;
  }

  void dispose() {
    if (_isInitialized) {
      _interpreter.close();
      _isInitialized = false;
    }
  }
} 