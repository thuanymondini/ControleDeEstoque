import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/alert_stripe_card.dart';
import '../widgets/app_header.dart';
import 'product_detail_screen.dart';

/// Tela Inicio: cabecalho roxo com a data, resumo do estoque e a lista dos
/// produtos com estoque baixo.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});

  /// Troca a aba da navegacao principal (0 Inicio, 1 Produtos, 2 Estoque Baixo).
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final lowStock = controller.lowStockProducts;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AppHeader(
            overline: 'Controle de Estoque',
            title: 'Início',
            subtitle: formatFullDate(DateTime.now()),
            bottomPadding: 20,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Produtos cadastrados',
                      value: '${controller.totalProducts}',
                      caption: 'itens registrados',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Estoque baixo',
                      value: '${controller.lowStockCount}',
                      caption: 'produtos em alerta',
                      danger: true,
                      onTap: () => onNavigate(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Estoque baixo', style: AppText.sectionTitle),
                if (lowStock.isNotEmpty)
                  InkWell(
                    onTap: () => onNavigate(2),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text('Ver todos', style: AppText.sectionAction),
                    ),
                  ),
              ],
            ),
          ),
          if (lowStock.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _AllGoodCard(),
            )
          else
            for (final product in lowStock.take(5))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _LowStockTile(product: product),
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.caption,
    this.danger = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String caption;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: danger ? AppColors.lowSurface : AppColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: danger ? AppColors.errorContainer : AppColors.card,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppText.cardLabel.copyWith(
                  color: danger ? AppColors.error : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: AppText.cardValue.copyWith(
                  color: danger ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                caption,
                style: AppText.cardCaption.copyWith(
                  color: danger ? AppColors.error : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card branco com a faixa vermelha a esquerda usado na tela inicial.
class _LowStockTile extends StatelessWidget {
  const _LowStockTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AlertStripeCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppText.itemTitle),
                const SizedBox(height: 3),
                Text(
                  'Mínimo: ${product.minStock} unid.',
                  style: AppText.itemSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.quantity}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: AppColors.error,
                ),
              ),
              const Text(
                'unid.',
                style: TextStyle(fontSize: 10, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllGoodCard extends StatelessWidget {
  const _AllGoodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppColors.onSuccessContainer,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nenhum produto abaixo do estoque mínimo.',
              style: AppText.itemSubtitle,
            ),
          ),
        ],
      ),
    );
  }
}
