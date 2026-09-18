import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
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
  late final InventoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InventoryController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InventoryScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Controle de Estoque',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeShell(),
      ),
    );
  }
}
