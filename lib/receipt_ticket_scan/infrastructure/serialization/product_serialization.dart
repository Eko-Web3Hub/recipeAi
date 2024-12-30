import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';

abstract class ProductSerialization {
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      sellPrice: json['sell_price'] as String,
      quantity: json['quantity'] as String,
    );
  }
}