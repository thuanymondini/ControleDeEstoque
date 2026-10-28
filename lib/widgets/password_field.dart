import 'package:flutter/material.dart';

/// Campo de senha com cadeado e botao de mostrar/ocultar.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.hintText = 'Sua senha',
    this.enabled = true,
    this.isNewPassword = false,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final bool enabled;

  /// Pede ao gerenciador de senhas para sugerir uma nova (cadastro).
  final bool isNewPassword;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: _obscure,
      textInputAction: widget.textInputAction,
      autofillHints: [
        widget.isNewPassword
            ? AutofillHints.newPassword
            : AutofillHints.password,
      ],
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.lock_outline, size: 20),
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Mostrar senha' : 'Ocultar senha',
          icon: Icon(
            _obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
    );
  }
}
