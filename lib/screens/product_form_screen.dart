import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_actions.dart';
import '../widgets/form_field_label.dart';

/// Cadastro e edicao de produto.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// Quando nulo, a tela funciona como cadastro.
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minStockController;
  late String _category;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _quantityController.text.trim().isNotEmpty &&
      _minStockController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _quantityController = TextEditingController(
      text: product != null ? '${product.quantity}' : '',
    );
    _minStockController = TextEditingController(
      text: product != null ? '${product.minStock}' : '',
    );
    _category = kCategories.contains(product?.category)
        ? product!.category
        : kCategories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) return 'Informe um número inteiro.';
    if (parsed < 0) return 'O valor não pode ser negativo.';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final controller = InventoryScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final name = _nameController.text.trim();
    final quantity = int.parse(_quantityController.text.trim());
    final minStock = int.parse(_minStockController.text.trim());

    if (_isEditing) {
      await controller.updateProduct(
        widget.product!.id,
        name: name,
        category: _category,
        quantity: quantity,
        minStock: minStock,
      );
    } else {
      await controller.addProduct(
        name: name,
        category: _category,
        quantity: quantity,
        minStock: minStock,
      );
    }

    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Produto atualizado com sucesso.'
              : 'Produto cadastrado com sucesso.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Cadastrar Produto'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const FormFieldLabel('Nome do produto', required: true),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Caneta Azul BIC',
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Informe o nome do produto.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Categoria', required: true),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    dropdownColor: AppColors.card,
                    items: [
                      for (final category in kCategories)
                        DropdownMenuItem(value: category, child: Text(category)),
                    ],
                    onChanged: _isSaving
                        ? null
                        : (value) => setState(
                              () => _category = value ?? kCategories.first,
                            ),
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Quantidade atual', required: true),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: '0'),
                    onChanged: (_) => setState(() {}),
                    validator: _validateNumber,
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Estoque mínimo', required: true),
                  TextFormField(
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: '0'),
                    onChanged: (_) => setState(() {}),
                    validator: _validateNumber,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 2),
                    child: Text(
                      'Alerta quando a quantidade atual for menor ou igual a '
                      'este valor.',
                      style: AppText.itemSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            BottomActions(
              confirmLabel: 'Salvar',
              isSaving: _isSaving,
              onConfirm: _canSave && !_isSaving ? _save : null,
              onCancel:
                  _isSaving ? null : () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}
