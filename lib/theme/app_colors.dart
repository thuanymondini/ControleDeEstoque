import 'package:flutter/material.dart';

/// Tokens extraidos do prototipo do Figma Make (paleta baseline do
/// Material 3, primary #6750A4 / error #B3261E).
class AppColors {
  const AppColors._();

  static const primary = Color(0xFF6750A4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE8DEF8);
  static const onPrimaryContainer = Color(0xFF1D192B);

  static const error = Color(0xFFB3261E);
  static const errorContainer = Color(0xFFF9DEDC);

  /// Fundo das telas.
  static const surface = Color(0xFFF7F2FA);

  /// Fundo da barra de navegacao inferior.
  static const surfaceContainer = Color(0xFFF3EDF7);

  /// Fundo das AppBars claras (detalhe, formularios).
  static const surfaceBright = Color(0xFFFFFBFE);

  static const card = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1C1B1F);
  static const onSurfaceVariant = Color(0xFF49454F);
  static const outlineVariant = Color(0xFFCAC4D0);

  /// Trilho das barras de progresso de estoque baixo.
  static const track = Color(0xFFE6E0E9);

  /// Card de resumo "Estoque baixo" na tela inicial.
  static const lowSurface = Color(0xFFFFF8F7);

  static const successContainer = Color(0xFFD1FAE5);
  static const onSuccessContainer = Color(0xFF065F46);

  static const dangerContainer = Color(0xFFFEE2E2);
  static const onDangerContainer = Color(0xFF991B1B);

  static const deleteContainer = Color(0xFFFFF0F0);
}

/// Cores do selo de categoria.
class CategoryStyle {
  const CategoryStyle(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

/// Categorias fixas do app, na ordem em que aparecem no prototipo.
const List<String> kCategories = [
  'Papelaria',
  'Informática',
  'Alimentos',
  'Limpeza',
  'Outros',
];

const Map<String, CategoryStyle> _categoryStyles = {
  'Papelaria': CategoryStyle(Color(0xFFE8DEF8), Color(0xFF4A148C)),
  'Informática': CategoryStyle(Color(0xFFD3E5FF), Color(0xFF0D47A1)),
  'Alimentos': CategoryStyle(Color(0xFFD1FAE5), Color(0xFF065F46)),
  'Limpeza': CategoryStyle(Color(0xFFCCE8E6), Color(0xFF00504D)),
  'Outros': CategoryStyle(Color(0xFFE7E0EC), Color(0xFF49454F)),
};

CategoryStyle categoryStyleOf(String category) =>
    _categoryStyles[category] ?? _categoryStyles['Outros']!;
