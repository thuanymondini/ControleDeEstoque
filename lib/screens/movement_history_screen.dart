import 'package:flutter/material.dart';

import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'product_detail_screen.dart';

/// Historico de movimentacoes. Sem [productId], mostra o historico completo.
class MovementHistoryScreen extends StatelessWidget {
  const MovementHistoryScreen({super.key, this.productId});

  final String? productId;

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final product = productId == null ? null : controller.findById(productId!);
    final movements = productId == null
        ? controller.movements
        : controller.movementsOf(productId!);

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico')),
      body: movements.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history,
                      size: 40,
                      color: AppColors.onSurfaceVariant,
                    ),
                    SizedBox(height: 12),
                    Text('Sem movimentações', style: AppText.sectionTitle),
                    SizedBox(height: 6),
                    Text(
                      'As entradas e saídas registradas aparecem aqui.',
                      textAlign: TextAlign.center,
                      style: AppText.itemSubtitle,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: movements.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 12),
                    child: Text(
                      product != null
                          ? product.name
                          : '${movements.length} movimentações',
                      style: AppText.sectionTitle,
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MovementTile(
                    movement: movements[index - 1],
                    showProduct: productId == null,
                  ),
                );
              },
            ),
    );
  }
}
