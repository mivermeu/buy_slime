import 'package:flutter/material.dart';
import '../models/shopping_item.dart';

class ShoppingListTile extends StatelessWidget {
  final ShoppingListItem item;
  final VoidCallback onToggleCompleted;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ShoppingListTile({
    super.key,
    required this.item,
    required this.onToggleCompleted,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      onDismissed: (direction) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: item.isCompleted ? 1 : 2,
        child: ListTile(
          leading: Checkbox(
            value: item.isCompleted,
            onChanged: (value) => onToggleCompleted(),
            activeColor: Colors.green,
          ),
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: item.isCompleted
                  ? Colors.grey
                  : Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: item.isCompleted
                  ? FontWeight.normal
                  : FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity: ${item.quantity}',
                style: TextStyle(
                  color: item.isCompleted
                      ? Colors.grey
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              if (item.category != null && item.category!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category!,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: onEdit,
            tooltip: 'Edit item',
          ),
          tileColor: item.isCompleted
              ? Colors.grey.withValues(alpha: 0.1)
              : null,
        ),
      ),
    );
  }
}
