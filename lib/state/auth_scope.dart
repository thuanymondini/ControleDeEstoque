import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

/// Disponibiliza o [AuthController] para toda a arvore de widgets, no mesmo
/// formato do InventoryScope.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  /// Use quando a tela precisa reconstruir ao entrar/sair.
  static AuthController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope nao encontrado na arvore.');
    return scope!.notifier!;
  }

  /// Use em callbacks (onPressed, etc.) para apenas disparar acoes.
  static AuthController read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'AuthScope nao encontrado na arvore.');
    return scope!.notifier!;
  }
}
