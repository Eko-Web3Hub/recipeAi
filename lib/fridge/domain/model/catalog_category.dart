import 'package:equatable/equatable.dart';

/// A category of the shared ingredient catalog (`Categories/{catId}`), used
/// as the store aisle the shopping list groups its items by.
///
/// [order] is optional in Firestore: categories without it come after the
/// ordered ones, sorted by name.
class CatalogCategory extends Equatable {
  const CatalogCategory({
    required this.id,
    required this.name,
    this.nameFr,
    this.order,
  });

  final String id;
  final String name;
  final String? nameFr;
  final int? order;

  String displayName(String languageCode) =>
      languageCode == 'fr' && (nameFr?.isNotEmpty ?? false) ? nameFr! : name;

  @override
  List<Object?> get props => [id, name, nameFr, order];
}
