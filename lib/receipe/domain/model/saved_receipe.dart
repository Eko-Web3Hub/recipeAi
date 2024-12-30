
import 'package:equatable/equatable.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';

class SavedReceipe extends Equatable {
  const SavedReceipe({
    required this.receipe,
    required this.documentId,
  });

  final Receipe receipe;
  final String documentId;

  @override
  List<Object?> get props => [receipe, documentId];
}
