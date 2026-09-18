import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Cabecalho colorido das telas principais (roxo no Inicio/Produtos,
/// vermelho no Estoque Baixo), como no prototipo.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.overline,
    this.subtitle,
    this.color = AppColors.primary,
    this.bottom,
    this.bottomPadding = 16,
  });

  final String title;
  final String? overline;
  final String? subtitle;
  final Color color;

  /// Conteudo extra dentro do cabecalho (ex.: campo de pesquisa).
  final Widget? bottom;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 20,
        16,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overline != null) ...[
            Text(overline!.toUpperCase(), style: AppText.headerOverline),
            const SizedBox(height: 6),
          ],
          Text(title, style: AppText.headerTitle),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: AppText.headerSubtitle),
          ],
          if (bottom != null) ...[
            const SizedBox(height: 14),
            bottom!,
          ],
        ],
      ),
    );
  }
}
