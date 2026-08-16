class Product {
  final String id;
  final String name;
  final double price;
  final double cost;
  final int quantity;
  final String barcode;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.quantity,
    required this.barcode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cost': cost,
      'quantity': quantity,
      'barcode': barcode,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      barcode: json['barcode'] ?? '',
    );
  }
}
