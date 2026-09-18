enum MovementType {
  entry('Entrada'),
  exit('Saída');

  const MovementType(this.label);

  final String label;
}

/// Registro historico de uma entrada ou saida de estoque.
class StockMovement {
  const StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.note = '',
  });

  final String id;
  final String productId;
  final String productName;
  final MovementType type;
  final int quantity;
  final DateTime date;

  /// Observacao opcional digitada na tela de movimentacao.
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'type': type.name,
        'quantity': quantity,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: MovementType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => MovementType.entry,
      ),
      quantity: (json['quantity'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );
  }
}
