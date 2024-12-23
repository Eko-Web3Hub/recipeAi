import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.name,
    required this.quantity,
    required this.price,
  });

  final String name;
  final String quantity;
  final String price;

  @override
  List<Object?> get props => [name, quantity, price];
}

class ReceiptTicket extends Equatable {
  const ReceiptTicket({
    required this.superMarketName,
    required this.adresse,
    required this.date,
    required this.products,
  });

  final String superMarketName;
  final String adresse;
  final String date;
  final List<Product> products;

  @override
  List<Object?> get props => [];
}
