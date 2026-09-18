import 'package:flutter/material.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';
import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_chips.dart';
import 'movement_history_screen.dart';
import 'product_form_screen.dart';
import 'stock_movement_screen.dart';

/// Detalhes do produto: quantidades, informacoes, acoes e ultimas
/// movimentacoes.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceBright,
        title: const Text('Excluir produto'),
        content: Text(
          'Excluir "${product.name}"? Essa ação não pode ser desfeita e '
          'também remove o histórico de movimentações do produto.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final controller = InventoryScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await controller.deleteProduct(product.id);
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('"${product.name}" foi excluído.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final product = controller.findById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes do Produto')),
        body: const Center(child: Text('Produto não encontrado.')),
      );
    }

    final movements = controller.movementsOf(product.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Produto')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryChip(category: product.category),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                if (product.isLowStock) ...[
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: Color(0xFFFFB4AB),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Estoque abaixo do mínimo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFB4AB),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Qtd. atual',
                    value: '${product.quantity}',
                    color: product.isLowStock
                        ? AppColors.error
                        : AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Est. mínimo',
                    value: '${product.minStock}',
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INFORMAÇÕES', style: AppText.cardLabel),
                  const SizedBox(height: 6),
                  _InfoRow(label: 'Nome', value: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  )),
                  const Divider(),
                  _InfoRow(
                    label: 'Categoria',
                    value: CategoryChip(category: product.category),
                  ),
                  const Divider(),
                  _InfoRow(
                    label: 'Status',
                    value: Text(
                      product.isLowStock ? 'Estoque baixo' : 'Estoque normal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: product.isLowStock
                            ? AppColors.error
                            : AppColors.onSuccessContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('AÇÕES', style: AppText.cardLabel),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.trending_up,
                        label: 'Entrada de estoque',
                        background: AppColors.successContainer,
                        foreground: AppColors.onSuccessContainer,
                        onTap: () => _openMovement(
                          context,
                          product,
                          MovementType.entry,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.trending_down,
                        label: 'Saída de estoque',
                        background: AppColors.dangerContainer,
                        foreground: AppColors.onDangerContainer,
                        onTap: product.quantity > 0
                            ? () => _openMovement(
                                  context,
                                  product,
                                  MovementType.exit,
                                )
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Editar produto',
                        background: AppColors.primaryContainer,
                        foreground: AppColors.onPrimaryContainer,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ProductFormScreen(product: product),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.delete_outline,
                        label: 'Excluir produto',
                        background: AppColors.deleteContainer,
                        foreground: AppColors.error,
                        borderColor: AppColors.errorContainer,
                        onTap: () => _confirmDelete(context, product),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _HistoryButton(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MovementHistoryScreen(
                        productId: product.id,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('ÚLTIMAS MOVIMENTAÇÕES', style: AppText.cardLabel),
          ),
          if (movements.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Nenhuma movimentação registrada para este produto.',
                  style: AppText.itemSubtitle,
                ),
              ),
            )
          else
            for (final movement in movements.take(3))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: MovementTile(movement: movement),
              ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _openMovement(
    BuildContext context,
    Product product,
    MovementType type,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockMovementScreen(
          productId: product.id,
          initialType: type,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: AppText.cardLabel),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.cardValue.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          const Text('unidades', style: AppText.cardCaption),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Flexible(child: Align(alignment: Alignment.centerRight, child: value)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.borderColor,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: borderColor == null
                  ? null
                  : Border.all(color: borderColor!),
            ),
            child: Column(
              children: [
                Icon(icon, size: 20, color: foreground),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  const _HistoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(width: 10),
              Text(
                'Ver histórico de movimentações',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha do historico de movimentacoes.
class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.movement, this.showProduct = false});

  final StockMovement movement;
  final bool showProduct;

  @override
  Widget build(BuildContext context) {
    final isEntry = movement.type == MovementType.entry;
    final color =
        isEntry ? AppColors.onSuccessContainer : AppColors.onDangerContainer;
    final background =
        isEntry ? AppColors.successContainer : AppColors.dangerContainer;

    final subtitle = StringBuffer(formatDate(movement.date));
    if (movement.note.isNotEmpty) {
      subtitle.write(' · ${movement.note}');
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: background, shape: BoxShape.circle),
            child: Icon(
              isEntry ? Icons.trending_up : Icons.trending_down,
              size: 17,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showProduct ? movement.productName : movement.type.label,
                  style: AppText.itemTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  showProduct
                      ? '${movement.type.label} · $subtitle'
                      : subtitle.toString(),
                  style: AppText.itemSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isEntry ? '+' : '-'}${movement.quantity}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
