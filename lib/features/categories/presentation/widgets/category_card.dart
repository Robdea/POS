import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          Icons.category_outlined,
          color: scheme.primary,
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: category.description == null
            ? null
            : Text(
                category.description!,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
        isThreeLine: false,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: scheme.onSurfaceVariant,
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: scheme.error,
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}