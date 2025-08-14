import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/shopping_item.dart';
import '../widgets/shopping_list_tile.dart';
import '../widgets/add_item_dialog.dart';
import '../services/storage_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<ShoppingListItem> _items = [];
  bool _isLoading = true;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadShoppingList();
  }

  Future<void> _loadShoppingList() async {
    try {
      final items = await StorageService.loadShoppingList();
      setState(() {
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load shopping list: $e');
    }
  }

  Future<void> _saveShoppingList() async {
    try {
      await StorageService.saveShoppingList(_items);
    } catch (e) {
      _showErrorSnackBar('Failed to save shopping list: $e');
    }
  }

  void _addItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddItemDialog(),
    );

    if (result != null) {
      final newItem = ShoppingListItem(
        id: _uuid.v4(),
        name: result['name'],
        quantity: result['quantity'],
        category: result['category'],
      );

      setState(() {
        _items.add(newItem);
      });
      _saveShoppingList();
    }
  }

  void _editItem(ShoppingListItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddItemDialog(itemToEdit: item),
    );

    if (result != null) {
      setState(() {
        final index = _items.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _items[index] = item.copyWith(
            name: result['name'],
            quantity: result['quantity'],
            category: result['category'],
          );
        }
      });
      _saveShoppingList();
    }
  }

  void _toggleItemCompletion(String itemId) {
    setState(() {
      final index = _items.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(
          isCompleted: !_items[index].isCompleted,
        );
      }
    });
    _saveShoppingList();
  }

  void _deleteItem(String itemId) {
    setState(() {
      _items.removeWhere((item) => item.id == itemId);
    });
    _saveShoppingList();
  }

  void _clearCompletedItems() {
    setState(() {
      _items.removeWhere((item) => item.isCompleted);
    });
    _saveShoppingList();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Completed items cleared')));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Your shopping list is empty',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first item',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final completedCount = _items.where((item) => item.isCompleted).length;
    final totalCount = _items.length;

    if (totalCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '$totalCount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text('Total Items'),
            ],
          ),
          Column(
            children: [
              Text(
                '$completedCount',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text('Completed'),
            ],
          ),
          Column(
            children: [
              Text(
                '${totalCount - completedCount}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text('Remaining'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final completedItems = _items.where((item) => item.isCompleted).toList();
    final pendingItems = _items.where((item) => !item.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buy Slime!'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (completedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear completed items',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Completed Items'),
                    content: Text(
                      'Are you sure you want to remove ${completedItems.length} completed items?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _clearCompletedItems();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _items.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildStats(),
                Expanded(
                  child: ListView(
                    children: [
                      // Pending items first
                      ...pendingItems.map(
                        (item) => ShoppingListTile(
                          item: item,
                          onToggleCompleted: () =>
                              _toggleItemCompletion(item.id),
                          onDelete: () => _deleteItem(item.id),
                          onEdit: () => _editItem(item),
                        ),
                      ),

                      // Completed items at the bottom
                      if (completedItems.isNotEmpty) ...[
                        if (pendingItems.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Text(
                            'Completed (${completedItems.length})',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ...completedItems.map(
                          (item) => ShoppingListTile(
                            item: item,
                            onToggleCompleted: () =>
                                _toggleItemCompletion(item.id),
                            onDelete: () => _deleteItem(item.id),
                            onEdit: () => _editItem(item),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}
