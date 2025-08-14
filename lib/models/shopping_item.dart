class ShoppingListItem {
  final String id;
  final String name;
  final int quantity;
  final bool isCompleted;
  final String? category;

  ShoppingListItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.isCompleted = false,
    this.category,
  });

  ShoppingListItem copyWith({
    String? id,
    String? name,
    int? quantity,
    bool? isCompleted,
    String? category,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      category: json['category'] as String?,
    );
  }
}

class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingListItem> items;

  ShoppingList({required this.id, required this.name, required this.items});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => ShoppingListItem.fromJson(item))
          .toList(),
    );
  }
}
