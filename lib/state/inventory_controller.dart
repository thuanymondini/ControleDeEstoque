import 'package:flutter/foundation.dart';

import '../data/inventory_repository.dart';
import '../models/product.dart';
import '../models/stock_movement.dart';

/// Erro de regra de negocio (ex.: saida maior que a quantidade disponivel).
class StockException implements Exception {
  StockException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Fonte unica de verdade do app: lista de produtos, historico de
/// movimentacoes e as regras de entrada/saida de estoque do usuario logado.
class InventoryController extends ChangeNotifier {
  InventoryController({InventoryRepository? repository})
      : _repository = repository ?? InventoryRepository();

  final InventoryRepository _repository;

  /// E-mail da conta dona do estoque carregado.
  String? _owner;
  List<Product> _products = [];
  List<StockMovement> _movements = [];
  bool _isLoading = true;

  String? get owner => _owner;

  bool get isLoading => _isLoading;

  /// Produtos na ordem de cadastro (igual ao prototipo).
  List<Product> get products => List.unmodifiable(_products);

  /// Movimentacoes da mais recente para a mais antiga.
  List<StockMovement> get movements => List.unmodifiable(_movements);

  List<Product> get lowStockProducts =>
      _products.where((product) => product.isLowStock).toList();

  int get totalProducts => _products.length;

  int get totalItemsInStock =>
      _products.fold(0, (total, product) => total + product.quantity);

  int get lowStockCount => lowStockProducts.length;

  /// Categorias existentes, usadas no filtro e como sugestao no cadastro.
  List<String> get categories {
    final set = _products.map((product) => product.category).toSet().toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return set;
  }

  /// Carrega o estoque de [owner], descartando o do usuario anterior.
  Future<void> load(String owner, {bool withSampleData = false}) async {
    _owner = owner;
    _products = [];
    _movements = [];
    _isLoading = true;
    notifyListeners();

    final products = await _repository.loadProducts(
      owner,
      withSampleData: withSampleData,
    );
    final movements = await _repository.loadMovements(owner);

    // Outro usuario entrou (ou saiu) enquanto este estoque carregava.
    if (_owner != owner) return;

    _products = products;
    _movements = movements;
    _sortMovements();

    _isLoading = false;
    notifyListeners();
  }

  /// Esvazia o estoque em memoria ao sair da conta.
  void clear() {
    _owner = null;
    _products = [];
    _movements = [];
    _isLoading = true;
    notifyListeners();
  }

  Product? findById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  /// Consulta combinando pesquisa por nome e filtro por categoria.
  ///
  /// [category] nulo significa "todas as categorias".
  List<Product> search({
    String query = '',
    String? category,
    bool onlyLowStock = false,
  }) {
    final normalizedQuery = _normalize(query);

    return _products.where((product) {
      final matchesQuery = normalizedQuery.isEmpty ||
          _normalize(product.name).contains(normalizedQuery);
      final matchesCategory = category == null || product.category == category;
      final matchesLowStock = !onlyLowStock || product.isLowStock;
      return matchesQuery && matchesCategory && matchesLowStock;
    }).toList();
  }

  // ---------------------------------------------------------------- CRUD

  Future<Product> addProduct({
    required String name,
    required String category,
    required int quantity,
    required int minStock,
  }) async {
    final product = Product(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      category: category.trim(),
      quantity: quantity,
      minStock: minStock,
    );

    _products = [..._products, product];
    await _repository.saveProducts(_owner!, _products);
    notifyListeners();
    return product;
  }

  Future<Product> updateProduct(
    String id, {
    required String name,
    required String category,
    required int quantity,
    required int minStock,
  }) async {
    final current = findById(id);
    if (current == null) {
      throw StockException('Produto não encontrado.');
    }

    final updated = current.copyWith(
      name: name.trim(),
      category: category.trim(),
      quantity: quantity,
      minStock: minStock,
    );

    _products = [
      for (final product in _products)
        if (product.id == id) updated else product,
    ];
    await _repository.saveProducts(_owner!, _products);
    notifyListeners();
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    _products = _products.where((product) => product.id != id).toList();
    _movements =
        _movements.where((movement) => movement.productId != id).toList();
    await _repository.saveProducts(_owner!, _products);
    await _repository.saveMovements(_owner!, _movements);
    notifyListeners();
  }

  // ------------------------------------------------- Entrada / Saida

  /// Entrada: acrescenta [quantity] ao estoque do produto.
  Future<Product> registerEntry(
    String productId,
    int quantity, {
    String note = '',
  }) {
    return _registerMovement(productId, quantity, MovementType.entry, note);
  }

  /// Saida: diminui [quantity] do estoque.
  ///
  /// Lanca [StockException] quando a saida e maior que a quantidade
  /// disponivel.
  Future<Product> registerExit(
    String productId,
    int quantity, {
    String note = '',
  }) {
    return _registerMovement(productId, quantity, MovementType.exit, note);
  }

  Future<Product> _registerMovement(
    String productId,
    int quantity,
    MovementType type,
    String note,
  ) async {
    if (quantity <= 0) {
      throw StockException('Informe uma quantidade maior que zero.');
    }

    final product = findById(productId);
    if (product == null) {
      throw StockException('Produto não encontrado.');
    }

    if (type == MovementType.exit && quantity > product.quantity) {
      throw StockException(
        'Saída maior que o disponível. Estoque atual: ${product.quantity}.',
      );
    }

    final newQuantity = type == MovementType.entry
        ? product.quantity + quantity
        : product.quantity - quantity;

    final updated = product.copyWith(quantity: newQuantity);
    _products = [
      for (final item in _products)
        if (item.id == productId) updated else item,
    ];

    _movements = [
      StockMovement(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        productId: product.id,
        productName: product.name,
        type: type,
        quantity: quantity,
        date: DateTime.now(),
        note: note.trim(),
      ),
      ..._movements,
    ];
    if (_movements.length > 100) {
      _movements = _movements.sublist(0, 100);
    }

    await _repository.saveProducts(_owner!, _products);
    await _repository.saveMovements(_owner!, _movements);
    notifyListeners();
    return updated;
  }

  List<StockMovement> movementsOf(String productId) =>
      _movements.where((movement) => movement.productId == productId).toList();

  // ------------------------------------------------------------- Helpers

  void _sortMovements() {
    _movements.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Deixa a busca insensivel a maiusculas e a acentos.
  static String _normalize(String value) {
    const withAccents = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const withoutAccents = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    final buffer = StringBuffer();
    for (final char in value.toLowerCase().trim().split('')) {
      final index = withAccents.indexOf(char);
      buffer.write(index >= 0 ? withoutAccents[index].toLowerCase() : char);
    }
    return buffer.toString();
  }
}
