import 'package:flutter/widgets.dart';

import 'inventory_controller.dart';

/// Disponibiliza o [InventoryController] para toda a arvore de widgets e
/// reconstroi quem o escuta a cada notifyListeners().
class InventoryScope extends InheritedNotifier<InventoryController> {
  const InventoryScope({
    super.key,
    required InventoryController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Use quando a tela precisa reconstruir ao mudar o estoque.
  static InventoryController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<InventoryScope>();
    assert(scope != null, 'InventoryScope nao encontrado na arvore.');
    return scope!.notifier!;
  }

  /// Use em callbacks (onPressed, etc.) para apenas disparar acoes.
  static InventoryController read(BuildContext context) {
    final scope =
        context.getInheritedWidgetOfExactType<InventoryScope>();
    assert(scope != null, 'InventoryScope nao encontrado na arvore.');
    return scope!.notifier!;
  }
}
