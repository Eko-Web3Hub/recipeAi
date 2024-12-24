import 'package:recipe_ai/receipt_ticket_scan/application/models/receipt_ticket.dart';
import 'package:recipe_ai/receipt_ticket_scan/infrastructure/serialization/product_serialization.dart';

abstract class ReceiptTicketScanSerialization {
  static ReceiptTicket fromJson(Map<String, dynamic> json) {
    return ReceiptTicket(
      superMarketName: json['super_market_name'] as String,
      adresse: json['adresse'] as String,
      date: json['date'] as String,
      totalPricePayed: json['total_price_payed'] as String,
      products: (json['products'] as List)
          .map<Product>(
            (product) => ProductSerialization.fromJson(product),
          )
          .toList(),
    );
  }
}
