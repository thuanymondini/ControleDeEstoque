import 'dart:convert';

import 'package:controle_estoque/data/inventory_repository.dart';
import 'package:controle_estoque/models/product.dart';
import 'package:controle_estoque/state/inventory_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const admin = 'admin@estoque.com';
const maria = 'maria@email.com';
const joao = 'joao@email.com';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('conta nova comeca com o estoque vazio', () async {
    final controller = InventoryController();
    await controller.load(maria);

    expect(controller.isLoading, isFalse);
    expect(controller.products, isEmpty);
    expect(controller.movements, isEmpty);
  });

  test('conta de demonstracao recebe os produtos de exemplo', () async {
    final controller = InventoryController();
    await controller.load(admin, withSampleData: true);

    expect(controller.products, isNotEmpty);
  });

  test('cada usuario ve apenas o proprio estoque', () async {
    final controller = InventoryController();

    await controller.load(maria);
    final caneta = await controller.addProduct(
      name: 'Caneta',
      category: 'Papelaria',
      quantity: 10,
      minStock: 2,
    );
    await controller.registerExit(caneta.id, 3);

    await controller.load(joao);
    expect(controller.products, isEmpty);
    expect(controller.movements, isEmpty);

    await controller.load(maria);
    expect(controller.products.single.name, 'Caneta');
    expect(controller.products.single.quantity, 7);
    expect(controller.movements, hasLength(1));
  });

  test('sair esvazia o estoque em memoria', () async {
    final controller = InventoryController();
    await controller.load(admin, withSampleData: true);

    controller.clear();

    expect(controller.owner, isNull);
    expect(controller.products, isEmpty);
  });

  test('estoque da versao sem contas vai so para a conta de demonstracao',
      () async {
    const legacy = Product(
      id: 'antigo',
      name: 'Produto antigo',
      category: 'Outros',
      quantity: 5,
      minStock: 1,
    );
    SharedPreferences.setMockInitialValues({
      'controle_estoque.seeded': true,
      'controle_estoque.products': [jsonEncode(legacy.toJson())],
      'controle_estoque.movements': <String>[],
    });
    final repository = InventoryRepository();

    expect(await repository.loadProducts(maria), isEmpty);

    final adminProducts = await repository.loadProducts(
      admin,
      withSampleData: true,
    );
    expect(adminProducts.single.name, 'Produto antigo');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('controle_estoque.products'), isFalse);
  });
}
