import 'package:controle_estoque/data/inventory_repository.dart';
import 'package:controle_estoque/models/product.dart';
import 'package:controle_estoque/models/stock_movement.dart';
import 'package:controle_estoque/state/inventory_controller.dart';
import 'package:flutter_test/flutter_test.dart';

/// Repositorio em memoria (de um unico usuario) para testar as regras sem
/// SharedPreferences.
class FakeRepository extends InventoryRepository {
  FakeRepository(this._products);

  List<Product> _products;
  List<StockMovement> _movements = [];

  @override
  Future<List<Product>> loadProducts(
    String owner, {
    bool withSampleData = false,
  }) async =>
      List.of(_products);

  @override
  Future<void> saveProducts(String owner, List<Product> products) async {
    _products = List.of(products);
  }

  @override
  Future<List<StockMovement>> loadMovements(String owner) async =>
      List.of(_movements);

  @override
  Future<void> saveMovements(
    String owner,
    List<StockMovement> movements,
  ) async {
    _movements = List.of(movements);
  }
}

Future<InventoryController> buildController(List<Product> products) async {
  final controller = InventoryController(repository: FakeRepository(products));
  await controller.load('teste@estoque.com');
  return controller;
}

void main() {
  const arroz = Product(
    id: '1',
    name: 'Arroz 5kg',
    category: 'Alimentos',
    quantity: 20,
    minStock: 5,
  );
  const detergente = Product(
    id: '2',
    name: 'Detergente',
    category: 'Limpeza',
    quantity: 5,
    minStock: 5,
  );
  const feijao = Product(
    id: '3',
    name: 'Feijão 1kg',
    category: 'Alimentos',
    quantity: 2,
    minStock: 10,
  );

  group('regra de estoque baixo', () {
    test('quantidade maior que o minimo nao e estoque baixo', () {
      expect(arroz.isLowStock, isFalse);
    });

    test('quantidade igual ao minimo e estoque baixo', () {
      expect(detergente.isLowStock, isTrue);
    });

    test('quantidade menor que o minimo e estoque baixo', () {
      expect(feijao.isLowStock, isTrue);
    });

    test('faltam unidades para o minimo', () {
      expect(feijao.missingToMinimum, 8);
      expect(detergente.missingToMinimum, 0);
      expect(arroz.missingToMinimum, 0);
    });

    test('progresso em relacao ao minimo', () {
      expect(feijao.minimumProgress, 0.2);
      expect(detergente.minimumProgress, 1.0);
      expect(arroz.minimumProgress, 1.0);
    });
  });

  group('entrada e saida', () {
    test('entrada acrescenta a quantidade informada', () async {
      final controller = await buildController([arroz]);

      final updated = await controller.registerEntry('1', 10);

      expect(updated.quantity, 30);
      expect(controller.findById('1')!.quantity, 30);
      expect(controller.movements.first.type, MovementType.entry);
    });

    test('saida diminui a quantidade informada', () async {
      final controller = await buildController([arroz]);

      final updated = await controller.registerExit('1', 8);

      expect(updated.quantity, 12);
      expect(controller.movements.first.type, MovementType.exit);
    });

    test('saida maior que o disponivel e bloqueada', () async {
      final controller = await buildController([feijao]);

      expect(
        () => controller.registerExit('3', 3),
        throwsA(isA<StockException>()),
      );
      expect(controller.findById('3')!.quantity, 2);
    });

    test('saida igual ao disponivel e permitida', () async {
      final controller = await buildController([feijao]);

      final updated = await controller.registerExit('3', 2);

      expect(updated.quantity, 0);
    });

    test('quantidade zero ou negativa e rejeitada', () async {
      final controller = await buildController([arroz]);

      expect(
        () => controller.registerEntry('1', 0),
        throwsA(isA<StockException>()),
      );
    });

    test('saida pode levar o produto para estoque baixo', () async {
      final controller = await buildController([arroz]);

      await controller.registerExit('1', 16);

      expect(controller.findById('1')!.isLowStock, isTrue);
      expect(controller.lowStockCount, 1);
    });
  });

  group('consulta', () {
    test('pesquisa por nome ignora acento e caixa', () async {
      final controller = await buildController([arroz, detergente, feijao]);

      final results = controller.search(query: 'FEIJAO');

      expect(results.map((p) => p.id), ['3']);
    });

    test('filtro por categoria', () async {
      final controller = await buildController([arroz, detergente, feijao]);

      final results = controller.search(category: 'Alimentos');

      expect(results.map((p) => p.id), ['1', '3']);
    });

    test('pesquisa e filtro combinados', () async {
      final controller = await buildController([arroz, detergente, feijao]);

      final results = controller.search(query: 'deter', category: 'Limpeza');

      expect(results.map((p) => p.id), ['2']);
    });

    test('lista de estoque baixo', () async {
      final controller = await buildController([arroz, detergente, feijao]);

      expect(controller.lowStockProducts.map((p) => p.id), ['2', '3']);
    });
  });

  group('cadastro, edicao e exclusao', () {
    test('cadastra produto no fim da lista', () async {
      final controller = await buildController([feijao]);

      await controller.addProduct(
        name: 'Acucar',
        category: 'Alimentos',
        quantity: 10,
        minStock: 3,
      );

      expect(controller.products.map((p) => p.name), ['Feijão 1kg', 'Acucar']);
      expect(controller.totalProducts, 2);
    });

    test('edita produto', () async {
      final controller = await buildController([arroz]);

      final updated = await controller.updateProduct(
        '1',
        name: 'Arroz 1kg',
        category: 'Mercearia',
        quantity: 4,
        minStock: 6,
      );

      expect(updated.name, 'Arroz 1kg');
      expect(updated.isLowStock, isTrue);
      expect(controller.categories, ['Mercearia']);
    });

    test('exclui produto e suas movimentacoes', () async {
      final controller = await buildController([arroz, detergente]);
      await controller.registerEntry('1', 5);

      await controller.deleteProduct('1');

      expect(controller.findById('1'), isNull);
      expect(controller.movements, isEmpty);
      expect(controller.totalProducts, 1);
    });
  });

  test('totais do resumo', () async {
    final controller = await buildController([arroz, detergente, feijao]);

    expect(controller.totalProducts, 3);
    expect(controller.totalItemsInStock, 27);
    expect(controller.lowStockCount, 2);
  });
}
