// This is a basic Flutter widget test for the Shopping List app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:buy_slime/models/shopping_item.dart';
import 'package:buy_slime/widgets/shopping_list_tile.dart';
import 'package:buy_slime/widgets/add_item_dialog.dart';

void main() {
  group('Shopping Item Model Tests', () {
    test('ShoppingListItem can be created and serialized', () {
      const uuid = Uuid();
      final item = ShoppingListItem(
        id: uuid.v4(),
        name: 'Test Item',
        quantity: 2,
        isCompleted: false,
        category: 'Test Category',
      );

      expect(item.name, 'Test Item');
      expect(item.quantity, 2);
      expect(item.isCompleted, false);
      expect(item.category, 'Test Category');

      // Test JSON serialization
      final json = item.toJson();
      final fromJson = ShoppingListItem.fromJson(json);
      expect(fromJson.name, item.name);
      expect(fromJson.quantity, item.quantity);
      expect(fromJson.isCompleted, item.isCompleted);
    });

    test('ShoppingListItem copyWith works correctly', () {
      const uuid = Uuid();
      final item = ShoppingListItem(
        id: uuid.v4(),
        name: 'Original',
        quantity: 1,
        isCompleted: false,
      );

      final updated = item.copyWith(name: 'Updated', isCompleted: true);

      expect(updated.name, 'Updated');
      expect(updated.quantity, 1); // unchanged
      expect(updated.isCompleted, true);
    });
  });

  group('Widget Tests', () {
    testWidgets('ShoppingListTile displays item correctly', (
      WidgetTester tester,
    ) async {
      const uuid = Uuid();
      final item = ShoppingListItem(
        id: uuid.v4(),
        name: 'Test Item',
        quantity: 3,
        isCompleted: false,
        category: 'Groceries',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShoppingListTile(
              item: item,
              onToggleCompleted: () {},
              onDelete: () {},
              onEdit: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Quantity: 3'), findsOneWidget);
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('AddItemDialog displays correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AddItemDialog())),
      );

      expect(find.text('Add New Item'), findsOneWidget);
      expect(find.text('Item Name'), findsOneWidget);
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Category (optional)'), findsOneWidget);
    });
  });
}
