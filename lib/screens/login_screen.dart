import 'package:flutter/material.dart';

import '../state/auth_controller.dart';
import '../state/auth_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_header.dart';
import '../widgets/error_banner.dart';
import '../widgets/form_field_label.dart';
import '../widgets/password_field.dart';
import 'register_screen.dart';

/// Tela de login: cabecalho roxo igual ao das telas principais e card branco
/// com e-mail e senha.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  void _fillDemoAccess() {
    _emailController.text = AuthController.demoEmail;
    _passwordController.text = AuthController.demoPassword;
    _clearError();
  }

  void _openRegister() {
    _clearError();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = AuthScope.read(context);
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      // Ao entrar, o MaterialApp troca esta tela pela HomeShell.
      await auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const AppHeader(
            overline: 'Controle de Estoque',
            title: 'Bem-vindo',
            subtitle: 'Entre para gerenciar seus produtos e movimentações.',
            bottomPadding: 24,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CardTitle(),
                      const SizedBox(height: 20),
                      if (_error != null) ...[
                        ErrorBanner(message: _error!),
                        const SizedBox(height: 16),
                      ],
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
                        onChanged: (_) => _clearError(),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 16),
                      const FormFieldLabel('Senha', required: true),
                      PasswordField(
                        controller: _passwordController,
                        enabled: !_isSubmitting,
                        onChanged: (_) => _clearError(),
                        onFieldSubmitted: (_) => _submit(),
                        validator: (value) =>
                            (value ?? '').isEmpty ? 'Informe a senha.' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.track,
                          disabledForegroundColor: AppColors.onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Não tem uma conta?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                TextButton(
                  onPressed: _isSubmitting ? null : _openRegister,
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            child: _DemoAccessCard(
              onFill: _isSubmitting ? null : _fillDemoAccess,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
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
                'Entrar',
                style: AppText.sectionTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              const Text(
                'Use seu e-mail e senha de acesso.',
                style: AppText.itemSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Card lilas com a conta de demonstracao criada na primeira execucao.
class _DemoAccessCard extends StatelessWidget {
  const _DemoAccessCard({required this.onFill});

  final VoidCallback? onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppColors.onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acesso de demonstração',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${AuthController.demoEmail} · ${AuthController.demoPassword}',
                  style: AppText.itemSubtitle,
                ),
              ],
            ),
          ),
          TextButton(onPressed: onFill, child: const Text('Preencher')),
        ],
      ),
    );
  }
}
