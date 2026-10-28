import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import '../state/auth_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/bottom_actions.dart';
import '../widgets/error_banner.dart';
import '../widgets/form_field_label.dart';
import '../widgets/password_field.dart';

/// Criacao de conta, no mesmo formato dos formularios de produto. Ao criar,
/// o usuario ja entra no app.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// Reconstroi para atualizar o botao e some com o erro ao editar.
  void _onFieldChanged(String _) => setState(() => _error = null);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final name = _nameController.text.trim();

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await auth.register(
        name: name,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = error.message;
      });
      return;
    }

    // A sessao ja foi aberta: o MaterialApp troca o login pela HomeShell, e
    // basta fechar esta tela.
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Conta criada! Boas-vindas, ${name.split(' ').first}!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: AutofillGroup(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    const _IntroCard(),
                    const SizedBox(height: 20),
                    if (_error != null) ...[
                      ErrorBanner(message: _error!),
                      const SizedBox(height: 16),
                    ],
                    const FormFieldLabel('Nome', required: true),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isSubmitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: const InputDecoration(
                        hintText: 'Ex: Maria Silva',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                      onChanged: _onFieldChanged,
                      validator: (value) => (value ?? '').trim().isEmpty
                          ? 'Informe o seu nome.'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    const FormFieldLabel('E-mail', required: true),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isSubmitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'seu@email.com',
                        prefixIcon: Icon(Icons.mail_outline, size: 20),
                      ),
                      onChanged: _onFieldChanged,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 20),
                    const FormFieldLabel('Senha', required: true),
                    PasswordField(
                      controller: _passwordController,
                      enabled: !_isSubmitting,
                      hintText: 'Crie uma senha',
                      isNewPassword: true,
                      textInputAction: TextInputAction.next,
                      onChanged: _onFieldChanged,
                      validator: (value) =>
                          (value ?? '').length <
                              AuthController.minPasswordLength
                          ? 'Use pelo menos '
                                '${AuthController.minPasswordLength} '
                                'caracteres.'
                          : null,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, left: 2),
                      child: Text(
                        'Mínimo de ${AuthController.minPasswordLength} '
                        'caracteres.',
                        style: AppText.itemSubtitle,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const FormFieldLabel('Confirmar senha', required: true),
                    PasswordField(
                      controller: _confirmController,
                      enabled: !_isSubmitting,
                      hintText: 'Repita a senha',
                      isNewPassword: true,
                      onChanged: _onFieldChanged,
                      onFieldSubmitted: (_) {
                        if (_canSubmit && !_isSubmitting) _submit();
                      },
                      validator: (value) => value != _passwordController.text
                          ? 'As senhas não conferem.'
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            BottomActions(
              confirmLabel: 'Criar conta',
              isSaving: _isSubmitting,
              onConfirm: _canSubmit && !_isSubmitting ? _submit : null,
              onCancel: _isSubmitting
                  ? null
                  : () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_add_alt_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova conta',
                  style: AppText.sectionTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Preencha seus dados para acessar o controle de estoque.',
                  style: AppText.itemSubtitle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
