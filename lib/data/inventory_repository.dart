import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';

/// Persistencia local simples (SharedPreferences + JSON).
///
/// Cada usuario tem o proprio estoque: as chaves levam o e-mail da conta
/// ([owner]).
///
/// Fica isolada atras desta classe para que trocar por um banco (sqflite,
/// Isar) ou por uma API nao exija mudanca nas telas.
class InventoryRepository {
  // Chaves da versao sem contas, quando o aparelho tinha um unico estoque.
  static const _legacyProductsKey = 'controle_estoque.products';
  static const _legacyMovementsKey = 'controle_estoque.movements';
  static const _legacySeededKey = 'controle_estoque.seeded';

  static String _productsKey(String owner) =>
      'controle_estoque.products.$owner';
  static String _movementsKey(String owner) =>
      'controle_estoque.movements.$owner';
  static String _seededKey(String owner) => 'controle_estoque.seeded.$owner';

  /// Produtos do usuario. Contas novas comecam com o estoque vazio.
  ///
  /// Com [withSampleData] (conta de demonstracao), a primeira carga assume o
  /// estoque da versao sem contas, se houver, ou os produtos de exemplo.
  Future<List<Product>> loadProducts(
    String owner, {
    bool withSampleData = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (withSampleData && prefs.getBool(_seededKey(owner)) != true) {
      await prefs.setBool(_seededKey(owner), true);
      if (prefs.getBool(_legacySeededKey) == true) {
        await _moveLegacyData(prefs, owner);
      } else {
        await saveProducts(owner, _seedProducts);
        return List.of(_seedProducts);
      }
    }

    final raw = prefs.getStringList(_productsKey(owner)) ?? const [];
    return raw
        .map((item) => Product.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProducts(String owner, List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _productsKey(owner),
      products.map((product) => jsonEncode(product.toJson())).toList(),
    );
  }

  Future<List<StockMovement>> loadMovements(String owner) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_movementsKey(owner)) ?? const [];
    return raw
        .map((item) =>
            StockMovement.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMovements(
    String owner,
    List<StockMovement> movements,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _movementsKey(owner),
      movements.map((movement) => jsonEncode(movement.toJson())).toList(),
    );
  }

  /// Passa o estoque unico da versao sem contas para [owner] e apaga as
  /// chaves antigas, para que nenhuma outra conta o receba.
  Future<void> _moveLegacyData(SharedPreferences prefs, String owner) async {
    await prefs.setStringList(
      _productsKey(owner),
      prefs.getStringList(_legacyProductsKey) ?? const [],
    );
    await prefs.setStringList(
      _movementsKey(owner),
      prefs.getStringList(_legacyMovementsKey) ?? const [],
    );
    await prefs.remove(_legacyProductsKey);
    await prefs.remove(_legacyMovementsKey);
    await prefs.remove(_legacySeededKey);
  }

  /// Dados de exemplo para a primeira execucao, iguais aos do prototipo.
  static const List<Product> _seedProducts = [
    Product(
      id: 'seed-1',
      name: 'Caderno A4 Universitário',
      category: 'Papelaria',
      quantity: 3,
      minStock: 10,
    ),
    Product(
      id: 'seed-2',
      name: 'Caneta Esferográfica Azul',
      category: 'Papelaria',
      quantity: 8,
      minStock: 20,
    ),
    Product(
      id: 'seed-3',
      name: 'Resma de Papel A4',
      category: 'Papelaria',
      quantity: 12,
      minStock: 5,
    ),
    Product(
      id: 'seed-4',
      name: 'Toner HP LaserJet',
      category: 'Informática',
      quantity: 2,
      minStock: 3,
    ),
    Product(
      id: 'seed-5',
      name: 'Mouse sem Fio Logitech',
      category: 'Informática',
      quantity: 15,
      minStock: 5,
    ),
    Product(
      id: 'seed-6',
      name: 'Garrafa de Água 500ml',
      category: 'Alimentos',
      quantity: 4,
      minStock: 12,
    ),
    Product(
      id: 'seed-7',
      name: 'Café em Pó 500g',
      category: 'Alimentos',
      quantity: 1,
      minStock: 5,
    ),
    Product(
      id: 'seed-8',
      name: 'Fita Adesiva Transparente',
      category: 'Papelaria',
      quantity: 6,
      minStock: 10,
    ),
  ];
}
