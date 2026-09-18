/// Produto do estoque.
///
/// Regra de negocio central do app: um produto esta com estoque baixo quando
/// a quantidade atual e menor ou igual ao estoque minimo.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.minStock,
  });

  final String id;
  final String name;
  final String category;
  final int quantity;
  final int minStock;

  /// quantidade atual <= estoque minimo
  bool get isLowStock => quantity <= minStock;

  /// Unidades que faltam para atingir o estoque minimo.
  int get missingToMinimum {
    final missing = minStock - quantity;
    return missing > 0 ? missing : 0;
  }

  /// Fracao do estoque minimo ja atendida (0..1), usada na barra de progresso
  /// da tela de estoque baixo.
  double get minimumProgress {
    if (minStock <= 0) return 1;
    final progress = quantity / minStock;
    return progress.clamp(0.0, 1.0);
  }

  Product copyWith({
    String? name,
    String? category,
    int? quantity,
    int? minStock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'minStock': minStock,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toInt(),
      minStock: (json['minStock'] as num).toInt(),
    );
  }
}
