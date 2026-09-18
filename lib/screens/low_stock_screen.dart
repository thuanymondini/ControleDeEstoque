import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/alert_stripe_card.dart';
import '../widgets/app_chips.dart';
import '../widgets/app_header.dart';
import 'product_detail_screen.dart';

/// Tela Estoque Baixo: cabecalho vermelho de alerta e os produtos com
/// quantidade atual menor ou igual ao estoque minimo.
class LowStockScreen extends StatelessWidget {
  const LowStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final products = controller.lowStockProducts
      ..sort((a, b) => a.minimumProgress.compareTo(b.minimumProgress));

    return Scaffold(
      body: Column(
        children: [
          AppHeader(
            overline: 'Atenção',
            title: 'Estoque Baixo',
            subtitle: products.length == 1
                ? '1 produto abaixo do mínimo'
                : '${products.length} produtos abaixo do mínimo',
            color: AppColors.error,
            bottomPadding: 24,
          ),
          Expanded(
            child: products.isEmpty
                ? const _NoAlerts()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: products.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AlertCard(product: products[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final missing = product.missingToMinimum;

    return AlertStripeCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: AppText.itemTitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        CategoryChip(category: product.category),
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
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        'de ${product.minStock} mín.',
                        style: AppText.itemSubtitle.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                missing > 0
                    ? 'Faltam $missing ${missing == 1 ? 'unidade' : 'unidades'} '
                        'para o mínimo'
                    : 'Quantidade no limite do estoque mínimo',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: product.minimumProgress,
                  minHeight: 6,
                  backgroundColor: AppColors.track,
                  valueColor: const AlwaysStoppedAnimation(AppColors.error),
                ),
              ),
        ],
      ),
    );
  }
}

class _NoAlerts extends StatelessWidget {
  const _NoAlerts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppColors.onSuccessContainer,
            ),
            SizedBox(height: 12),
            Text('Tudo em ordem', style: AppText.sectionTitle),
            SizedBox(height: 6),
            Text(
              'Nenhum produto está com a quantidade atual igual ou abaixo do '
              'estoque mínimo.',
              textAlign: TextAlign.center,
              style: AppText.itemSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
