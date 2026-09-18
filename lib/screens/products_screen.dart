import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_chips.dart';
import '../widgets/app_header.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

/// Tela Produtos: pesquisa por nome e filtro por categoria.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final results = controller.search(query: _query, category: _category);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProductFormScreen()),
        ),
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.primary,
        elevation: 0,
        highlightElevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          AppHeader(
            title: 'Produtos',
            bottomPadding: 16,
            bottom: _SearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              onClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.card,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterPill(
                    label: 'Todas',
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final category in kCategories) ...[
                    const SizedBox(width: 8),
                    FilterPill(
                      label: category,
                      selected: _category == category,
                      onTap: () => setState(
                        () => _category = _category == category ? null : category,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? _EmptyResults(hasProducts: controller.totalProducts > 0)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    itemCount: results.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 10),
                          child: Text(
                            results.length == 1
                                ? '1 produto encontrado'
                                : '${results.length} produtos encontrados',
                            style: AppText.itemSubtitle.copyWith(fontSize: 12),
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ProductTile(product: results[index - 1]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(fontSize: 14, color: AppColors.onSurface),
              decoration: const InputDecoration(
                hintText: 'Pesquisar produto...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: onClear,
              child: const Icon(
                Icons.close,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: AppText.itemTitle),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        CategoryChip(category: product.category),
                        if (product.isLowStock) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'estoque baixo',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  QuantityChip(
                    quantity: product.quantity,
                    isLowStock: product.isLowStock,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'unid.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.hasProducts});

  final bool hasProducts;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasProducts ? Icons.search_off : Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              hasProducts
                  ? 'Nenhum produto encontrado'
                  : 'Nenhum produto cadastrado',
              style: AppText.sectionTitle,
            ),
            const SizedBox(height: 6),
            Text(
              hasProducts
                  ? 'Ajuste a pesquisa ou o filtro de categoria.'
                  : 'Toque no + para cadastrar o primeiro produto.',
              textAlign: TextAlign.center,
              style: AppText.itemSubtitle,
            ),
          ],
        ),
      ),
    );
  }
}
