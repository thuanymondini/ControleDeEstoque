import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../models/stock_movement.dart';

/// Persistencia local simples (SharedPreferences + JSON).
///
/// Fica isolada atras desta classe para que trocar por um banco (sqflite,
/// Isar) ou por uma API nao exija mudanca nas telas.
class InventoryRepository {
  static const _productsKey = 'controle_estoque.products';
  static const _movementsKey = 'controle_estoque.movements';
  static const _seededKey = 'controle_estoque.seeded';

  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_seededKey) != true) {
      await prefs.setBool(_seededKey, true);
      await saveProducts(_seedProducts);
      return List.of(_seedProducts);
    }

    final raw = prefs.getStringList(_productsKey) ?? const [];
    return raw
        .map((item) => Product.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _productsKey,
      products.map((product) => jsonEncode(product.toJson())).toList(),
    );
  }

  Future<List<StockMovement>> loadMovements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_movementsKey) ?? const [];
    return raw
        .map((item) =>
            StockMovement.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMovements(List<StockMovement> movements) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _movementsKey,
      movements.map((movement) => jsonEncode(movement.toJson())).toList(),
    );
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
