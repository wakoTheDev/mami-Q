import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../providers/nutrition_provider.dart';
import '../../models/shopping_item.dart';

class ShoppingListTab extends ConsumerWidget {
  const ShoppingListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListAsync = ref.watch(shoppingListProvider);
    
    return Column(
      children: [
        // Header with actions
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Shopping List',
                  style: AppTextStyles.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showClearAllDialog(context, ref),
                icon: const Icon(Icons.clear_all, color: Colors.red),
                label: const Text('Clear All', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        
        // Shopping list content
        Expanded(
          child: shoppingListAsync.when(
            data: (shoppingList) {
              if (shoppingList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your shopping list is empty',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add ingredients from meal plans to build your list',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              // Group items by category
              final groupedItems = <String, List<ShoppingItem>>{};
              for (final item in shoppingList) {
                final category = item.category ?? 'Other';
                groupedItems.putIfAbsent(category, () => []).add(item);
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                  final category = groupedItems.keys.elementAt(index);
                  final items = groupedItems[category]!;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(category),
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${items.length} items',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Items list
                        ...items.map((item) => ShoppingItemTile(
                          item: item,
                          onToggle: (isChecked) => _toggleItemChecked(ref, item, isChecked),
                          onRemove: () => _removeItem(ref, item),
                          onQuantityChange: (quantity) => _updateQuantity(ref, item, quantity),
                        )),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading shopping list',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(shoppingListProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return Icons.apple;
      case 'vegetables':
        return Icons.eco;
      case 'meat':
        return Icons.restaurant;
      case 'dairy':
        return Icons.local_drink;
      case 'grains':
        return Icons.grain;
      case 'spices':
        return Icons.scatter_plot;
      default:
        return Icons.shopping_basket;
    }
  }

  void _toggleItemChecked(WidgetRef ref, ShoppingItem item, bool isChecked) {
    ref.read(shoppingListProvider.notifier).toggleItemChecked(item.id, isChecked);
  }

  void _removeItem(WidgetRef ref, ShoppingItem item) {
    ref.read(shoppingListProvider.notifier).removeItem(item.id);
  }

  void _updateQuantity(WidgetRef ref, ShoppingItem item, String quantity) {
    ref.read(shoppingListProvider.notifier).updateItemQuantity(item.id, quantity);
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Shopping List'),
        content: const Text('Are you sure you want to remove all items from your shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(shoppingListProvider.notifier).clearAll();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class ShoppingItemTile extends StatelessWidget {
  final ShoppingItem item;
  final Function(bool) onToggle;
  final VoidCallback onRemove;
  final Function(String) onQuantityChange;

  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onRemove,
    required this.onQuantityChange,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: item.isChecked,
        onChanged: (value) => onToggle(value ?? false),
        activeColor: AppColors.success,
      ),
      title: Text(
        item.name,
        style: TextStyle(
          decoration: item.isChecked ? TextDecoration.lineThrough : null,
          color: item.isChecked ? Colors.grey[600] : null,
        ),
      ),
      subtitle: Text(
        item.quantity,
        style: TextStyle(
          color: item.isChecked ? Colors.grey[500] : Colors.grey[700],
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _showEditQuantityDialog(context),
            icon: const Icon(Icons.edit, size: 20),
            tooltip: 'Edit quantity',
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            tooltip: 'Remove item',
          ),
        ],
      ),
    );
  }

  void _showEditQuantityDialog(BuildContext context) {
    final controller = TextEditingController(text: item.quantity);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.name}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onQuantityChange(controller.text.trim());
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
