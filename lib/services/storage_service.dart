import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class StorageService {
  static const String _shoppingListKey = 'shopping_list_items';

  /// Save shopping list items to local storage
  static Future<void> saveShoppingList(List<ShoppingListItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = json.encode(jsonList);
      await prefs.setString(_shoppingListKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save shopping list: $e');
    }
  }

  /// Load shopping list items from local storage
  static Future<List<ShoppingListItem>> loadShoppingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_shoppingListKey);

      if (jsonString == null) {
        return [];
      }

      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) => ShoppingListItem.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to load shopping list: $e');
    }
  }

  /// Clear all shopping list items from storage
  static Future<void> clearShoppingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_shoppingListKey);
    } catch (e) {
      throw Exception('Failed to clear shopping list: $e');
    }
  }

  /// Check if there's any saved data
  static Future<bool> hasStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_shoppingListKey);
    } catch (e) {
      return false;
    }
  }
}
