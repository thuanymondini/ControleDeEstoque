import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Rotulo acima dos campos dos formularios ("Nome do produto *").
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.text, {super.key, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text.rich(
        TextSpan(
          text: text,
          style: AppText.fieldLabel,
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}
