import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.primary,
      onSecondary: AppColors.onPrimary,
      secondaryContainer: AppColors.primaryContainer,
      onSecondaryContainer: AppColors.onPrimaryContainer,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceBright,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.track,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 22,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        hintStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
        border: _fieldBorder(AppColors.outlineVariant),
        enabledBorder: _fieldBorder(AppColors.outlineVariant),
        focusedBorder: _fieldBorder(AppColors.primary, width: 1.6),
        errorBorder: _fieldBorder(AppColors.error),
        focusedErrorBorder: _fieldBorder(AppColors.error, width: 1.6),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF322F35),
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Estilos de texto do prototipo (tamanhos em px = pixels logicos).
class AppText {
  const AppText._();

  static const headerOverline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    color: Colors.white,
  );

  static const headerTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static const headerSubtitle = TextStyle(
    fontSize: 12,
    color: Colors.white,
  );

  static const cardLabel = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    color: AppColors.onSurfaceVariant,
  );

  static const cardValue = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.primary,
  );

  static const cardCaption = TextStyle(
    fontSize: 11,
    color: AppColors.onSurfaceVariant,
  );

  static const sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static const sectionAction = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const itemTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static const itemSubtitle = TextStyle(
    fontSize: 11,
    color: AppColors.onSurfaceVariant,
  );

  static const fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );
}
