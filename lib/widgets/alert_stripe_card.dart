import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Card branco com a faixa vermelha na lateral esquerda usado nas listas de
/// estoque baixo.
///
/// A faixa e um filho do Row (e nao uma borda), porque o Flutter nao aceita
/// borderRadius em bordas nao uniformes.
class AlertStripeCard extends StatelessWidget {
  const AlertStripeCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: AppColors.error),
              Expanded(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
