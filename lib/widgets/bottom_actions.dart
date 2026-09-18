import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra inferior com Cancelar / acao principal, igual a dos formularios do
/// prototipo.
class BottomActions extends StatelessWidget {
  const BottomActions({
    super.key,
    required this.confirmLabel,
    required this.onConfirm,
    required this.onCancel,
    this.isSaving = false,
  });

  final String confirmLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: AppColors.onSurfaceVariant,
                side: const BorderSide(color: AppColors.outlineVariant),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: onConfirm,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.track,
                disabledForegroundColor: AppColors.onSurfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}
