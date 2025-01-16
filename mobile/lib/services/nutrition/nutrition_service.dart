import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Singleton pattern
  static final NutritionService _instance = NutritionService._internal();
  factory NutritionService() => _instance;
  NutritionService._internal();

  Future<Map<String, dynamic>?> getNutritionalInfo(String foodItem) async {
    try {
      // Query Firestore for nutritional information
      final docRef = _firestore.collection('food_nutrition').doc(foodItem.toLowerCase());
      final doc = await docRef.get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch nutritional information: $e');
    }
  }

  Future<List<Map<String, dynamic>>> searchFoodItems(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('food_nutrition')
          .where('name', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('name', isLessThan: query.toLowerCase() + 'z')
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      throw Exception('Failed to search food items: $e');
    }
  }

  Future<void> submitFoodCorrection({
    required String originalFood,
    required String correctedFood,
    required String userId,
  }) async {
    try {
      await _firestore.collection('food_corrections').add({
        'originalFood': originalFood,
        'correctedFood': correctedFood,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit food correction: $e');
    }
  }

  double calculateServingSize(
    double baseAmount,
    String baseUnit,
    double targetAmount,
    String targetUnit,
  ) {
    // Convert everything to grams for calculation
    final baseInGrams = _convertToGrams(baseAmount, baseUnit);
    final targetInGrams = _convertToGrams(targetAmount, targetUnit);
    return targetInGrams / baseInGrams;
  }

  Map<String, dynamic> adjustNutritionalValues(
    Map<String, dynamic> baseNutrition,
    double servingSizeMultiplier,
  ) {
    final adjustedNutrition = <String, dynamic>{};
    
    baseNutrition.forEach((key, value) {
      if (value is num) {
        adjustedNutrition[key] = value * servingSizeMultiplier;
      } else {
        adjustedNutrition[key] = value;
      }
    });

    return adjustedNutrition;
  }

  double _convertToGrams(double amount, String unit) {
    switch (unit.toLowerCase()) {
      case 'g':
      case 'grams':
        return amount;
      case 'kg':
      case 'kilograms':
        return amount * 1000;
      case 'oz':
      case 'ounces':
        return amount * 28.3495;
      case 'lb':
      case 'pounds':
        return amount * 453.592;
      case 'ml':
      case 'milliliters':
        return amount; // Assuming density of 1g/ml for simplicity
      case 'l':
      case 'liters':
        return amount * 1000;
      case 'cup':
      case 'cups':
        return amount * 236.588;
      case 'tbsp':
      case 'tablespoon':
        return amount * 14.7868;
      case 'tsp':
      case 'teaspoon':
        return amount * 4.92892;
      default:
        throw ArgumentError('Unsupported unit: $unit');
    }
  }
} 