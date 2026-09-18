import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Selo da categoria do produto (cores por categoria, como no prototipo).
class CategoryChip extends StatelessWidget {
  const CategoryChip({super.key, required this.category, this.fontSize = 11});

  final String category;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = categoryStyleOf(category);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: style.foreground,
        ),
      ),
    );
  }
}

/// Selo com a quantidade em estoque: vermelho quando baixo, verde quando ok.
class QuantityChip extends StatelessWidget {
  const QuantityChip({
    super.key,
    required this.quantity,
    required this.isLowStock,
  });

  final int quantity;
  final bool isLowStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isLowStock
            ? AppColors.errorContainer
            : AppColors.successContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isLowStock ? AppColors.error : AppColors.onSuccessContainer,
        ),
      ),
    );
  }
}

/// Chip de filtro de categoria da tela de produtos.
class FilterPill extends StatelessWidget {
  const FilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
