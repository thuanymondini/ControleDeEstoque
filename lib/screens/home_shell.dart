import 'package:flutter/material.dart';

import '../state/inventory_scope.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'low_stock_screen.dart';
import 'products_screen.dart';

/// Casca da navegacao principal: Inicio | Produtos | Est. Baixo.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final controller = InventoryScope.of(context);

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onNavigate: _goTo),
          const ProductsScreen(),
          const LowStockScreen(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Início',
            ),
            const NavigationDestination(
              icon: Icon(Icons.layers_outlined),
              selectedIcon: Icon(Icons.layers),
              label: 'Produtos',
            ),
            NavigationDestination(
              icon: _LowStockIcon(
                count: controller.lowStockCount,
                icon: Icons.error_outline,
              ),
              selectedIcon: _LowStockIcon(
                count: controller.lowStockCount,
                icon: Icons.error,
              ),
              label: 'Est. Baixo',
            ),
          ],
        ),
      ),
    );
  }
}

class _LowStockIcon extends StatelessWidget {
  const _LowStockIcon({required this.count, required this.icon});

  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: AppColors.error,
      textStyle: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      label: Text('$count'),
      child: Icon(icon),
    );
  }
}
