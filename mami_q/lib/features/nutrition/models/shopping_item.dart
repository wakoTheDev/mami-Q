class ShoppingItem {
  final String id;
  final String name;
  final String quantity;
  final String? category;
  final bool isChecked;
  final DateTime addedAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.category,
    this.isChecked = false,
    required this.addedAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? quantity,
    String? category,
    bool? isChecked,
    DateTime? addedAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'category': category,
      'isChecked': isChecked,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      category: json['category'],
      isChecked: json['isChecked'] ?? false,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}