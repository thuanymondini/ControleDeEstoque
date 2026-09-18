import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/stock_movement.dart';
import '../state/inventory_controller.dart';
import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_chips.dart';
import '../widgets/bottom_actions.dart';
import '../widgets/form_field_label.dart';

/// Tela de entrada e saida de estoque.
class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({
    super.key,
    required this.productId,
    required this.initialType,
  });

  final String productId;
  final MovementType initialType;

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  late MovementType _type = widget.initialType;
  bool _isSaving = false;

  bool get _isEntry => _type == MovementType.entry;

  int get _quantity => int.tryParse(_quantityController.text.trim()) ?? 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final controller = InventoryScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final updated = _isEntry
          ? await controller.registerEntry(
              widget.productId,
              _quantity,
              note: _noteController.text,
            )
          : await controller.registerExit(
              widget.productId,
              _quantity,
              note: _noteController.text,
            );

      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${_type.label} registrada. Estoque atual: ${updated.quantity}.',
          ),
        ),
      );
    } on StockException catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);
    final product = controller.findById(widget.productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Movimentação')),
        body: const Center(child: Text('Produto não encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Movimentação')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PRODUTO', style: AppText.cardLabel),
                        const SizedBox(height: 6),
                        Text(
                          product.name,
                          style: AppText.itemTitle.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CategoryChip(category: product.category),
                            const SizedBox(width: 10),
                            Text(
                              'Qtd. atual: ',
                              style: AppText.itemSubtitle.copyWith(fontSize: 12),
                            ),
                            Text(
                              '${product.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Tipo de movimentação'),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeOption(
                          icon: Icons.trending_up,
                          label: 'Entrada',
                          selected: _isEntry,
                          background: AppColors.successContainer,
                          foreground: AppColors.onSuccessContainer,
                          onTap: _isSaving
                              ? null
                              : () => setState(() {
                                    _type = MovementType.entry;
                                    _formKey.currentState?.validate();
                                  }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TypeOption(
                          icon: Icons.trending_down,
                          label: 'Saída',
                          selected: !_isEntry,
                          background: AppColors.dangerContainer,
                          foreground: AppColors.onDangerContainer,
                          onTap: _isSaving
                              ? null
                              : () => setState(() {
                                    _type = MovementType.exit;
                                    _formKey.currentState?.validate();
                                  }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Quantidade', required: true),
                  TextFormField(
                    controller: _quantityController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(hintText: '0'),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      final quantity = int.tryParse((value ?? '').trim());
                      if (quantity == null || quantity <= 0) {
                        return 'Informe uma quantidade maior que zero.';
                      }
                      if (!_isEntry && quantity > product.quantity) {
                        return 'Saída maior que o disponível '
                            '(${product.quantity} unid.).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Data'),
                  TextFormField(
                    initialValue: formatDate(DateTime.now()),
                    readOnly: true,
                    enabled: false,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      fillColor: AppColors.surfaceContainer,
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const FormFieldLabel('Observação'),
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Ex: Compra mensal, reposição, distribuição...',
                    ),
                  ),
                ],
              ),
            ),
            BottomActions(
              confirmLabel: 'Confirmar ${_type.label}',
              isSaving: _isSaving,
              onConfirm: _quantity > 0 && !_isSaving ? _submit : null,
              onCancel:
                  _isSaving ? null : () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? background : AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? foreground : AppColors.outlineVariant,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? foreground : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? foreground : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

