import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nutrigenius/services/nutrition/nutrition_service.dart';

class FoodResultScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> recognitionResults;

  const FoodResultScreen({
    Key? key,
    required this.imageFile,
    required this.recognitionResults,
  }) : super(key: key);

  @override
  State<FoodResultScreen> createState() => _FoodResultScreenState();
}

class _FoodResultScreenState extends State<FoodResultScreen> {
  final NutritionService _nutritionService = NutritionService();
  bool _isLoading = true;
  Map<String, dynamic>? _nutritionInfo;
  String _selectedFood;
  double _servingSize = 100;
  String _servingUnit = 'g';
  List<String> _alternativeFoods = [];

  @override
  void initState() {
    super.initState();
    _selectedFood = widget.recognitionResults['topResult']['label'];
    _loadNutritionalInfo();
    _loadAlternatives();
  }

  Future<void> _loadNutritionalInfo() async {
    try {
      final info = await _nutritionService.getNutritionalInfo(_selectedFood);
      if (mounted) {
        setState(() {
          _nutritionInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load nutritional information');
      }
    }
  }

  Future<void> _loadAlternatives() async {
    try {
      final alternatives = await _nutritionService.searchFoodItems(_selectedFood);
      if (mounted) {
        setState(() {
          _alternativeFoods = alternatives
              .where((food) => food['name'] != _selectedFood)
              .map((food) => food['name'] as String)
              .toList();
        });
      }
    } catch (e) {
      // Silently handle error for alternatives
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _updateServingSize(String value) {
    final newSize = double.tryParse(value);
    if (newSize != null && newSize > 0) {
      setState(() => _servingSize = newSize);
    }
  }

  Map<String, dynamic> _getAdjustedNutrition() {
    if (_nutritionInfo == null) return {};

    final multiplier = _nutritionService.calculateServingSize(
      100, // Base serving size is 100g
      'g',
      _servingSize,
      _servingUnit,
    );

    return _nutritionService.adjustNutritionalValues(
      _nutritionInfo!,
      multiplier,
    );
  }

  Widget _buildNutritionTable() {
    final adjustedNutrition = _getAdjustedNutrition();
    if (adjustedNutrition.isEmpty) {
      return const Center(
        child: Text('No nutritional information available'),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Facts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(thickness: 2),
            Text(
              'Serving Size: $_servingSize $_servingUnit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            _buildNutrientRow('Calories', adjustedNutrition['calories'], 'kcal'),
            const Divider(),
            _buildNutrientRow('Total Fat', adjustedNutrition['fat'], 'g'),
            _buildNutrientRow('Saturated Fat', adjustedNutrition['saturatedFat'], 'g'),
            _buildNutrientRow('Trans Fat', adjustedNutrition['transFat'], 'g'),
            const Divider(),
            _buildNutrientRow('Cholesterol', adjustedNutrition['cholesterol'], 'mg'),
            _buildNutrientRow('Sodium', adjustedNutrition['sodium'], 'mg'),
            const Divider(),
            _buildNutrientRow('Total Carbohydrates', adjustedNutrition['carbohydrates'], 'g'),
            _buildNutrientRow('Dietary Fiber', adjustedNutrition['fiber'], 'g'),
            _buildNutrientRow('Sugars', adjustedNutrition['sugar'], 'g'),
            const Divider(),
            _buildNutrientRow('Protein', adjustedNutrition['protein'], 'g'),
            const Divider(),
            _buildNutrientRow('Vitamin D', adjustedNutrition['vitaminD'], 'mcg'),
            _buildNutrientRow('Calcium', adjustedNutrition['calcium'], 'mg'),
            _buildNutrientRow('Iron', adjustedNutrition['iron'], 'mg'),
            _buildNutrientRow('Potassium', adjustedNutrition['potassium'], 'mg'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, dynamic value, String unit) {
    if (value == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('${value.toStringAsFixed(1)} $unit'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Analysis'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Food Image
                  Image.file(
                    widget.imageFile,
                    height: 200,
                    fit: BoxFit.cover,
                  ),

                  // Food Selection
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identified Food',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedFood,
                          items: [_selectedFood, ..._alternativeFoods]
                              .map((food) => DropdownMenuItem(
                                    value: food,
                                    child: Text(food),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null && value != _selectedFood) {
                              setState(() {
                                _selectedFood = value;
                                _isLoading = true;
                              });
                              _loadNutritionalInfo();
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Serving Size Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: _servingSize.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Serving Size',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: _updateServingSize,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _servingUnit,
                            items: ['g', 'oz', 'cup', 'tbsp', 'tsp']
                                .map((unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _servingUnit = value);
                              }
                            },
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nutrition Information
                  _buildNutritionTable(),

                  // Correction Button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement food correction submission
                      },
                      child: const Text('Report Incorrect Food'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 