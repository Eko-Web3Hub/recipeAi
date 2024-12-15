import 'package:equatable/equatable.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

class UserReceipe extends Equatable {
  const UserReceipe({
    required this.receipes,
    required this.lastUpdatedDate,
  });

  final List<Receipe> receipes;
  final DateTime lastUpdatedDate;
  @override
  List<Object?> get props => [receipes, lastUpdatedDate];
}
