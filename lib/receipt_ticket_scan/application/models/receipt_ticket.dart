import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.name,
    required this.quantity,
    required this.sellPrice,
  });

  final String name;
  final String quantity;
  final String sellPrice;

  @override
  List<Object?> get props => [
        name,
        quantity,
        sellPrice,
      ];
}

class ReceiptTicket extends Equatable {
  const ReceiptTicket({
    required this.superMarketName,
    required this.adresse,
    required this.date,
    required this.products,
    required this.totalPricePayed,
  });

  final String superMarketName;
  final String adresse;
  final String date;
  final List<Product> products;
  final String totalPricePayed;

  @override
  List<Object?> get props => [];
}
