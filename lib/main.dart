import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'state/auth_controller.dart';
import 'state/auth_scope.dart';
import 'state/inventory_controller.dart';
import 'state/inventory_scope.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ControleEstoqueApp());
}

class ControleEstoqueApp extends StatefulWidget {
  const ControleEstoqueApp({super.key});

  @override
  State<ControleEstoqueApp> createState() => _ControleEstoqueAppState();
}

class _ControleEstoqueAppState extends State<ControleEstoqueApp> {
  late final AuthController _auth;
  late final InventoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InventoryController();
    _auth = AuthController()..addListener(_syncInventory);
    _auth.load();
  }

  /// Cada conta tem o proprio estoque: ao entrar, carrega o do usuario; ao
  /// sair, esvazia o que estava em memoria.
  void _syncInventory() {
    final email = _auth.currentUser?.email;
    if (email == _controller.owner) return;

    if (email == null) {
      _controller.clear();
    } else {
      _controller.load(
        email,
        withSampleData: email == AuthController.demoEmail,
      );
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_syncInventory);
    _auth.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      controller: _auth,
      child: InventoryScope(
        controller: _controller,
        child: MaterialApp(
          title: 'Controle de Estoque',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

/// Mostra o login ate existir uma sessao; depois, a navegacao principal.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);

    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.isAuthenticated ? const HomeShell() : const LoginScreen();
  }
}
