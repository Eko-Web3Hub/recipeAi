import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

/// A shopping list (`ShoppingLists/{listId}`).
///
/// [memberIds] holds every user who can see and edit the list, [ownerId]
/// included. Collaborators join it through an invitation link.
class ShoppingList extends Equatable {
  const ShoppingList({
    required this.id,
    required this.name,
    required this.date,
    required this.ownerId,
    required this.memberIds,
    this.memberNames = const {},
    this.inviteToken,
    this.itemCount = 0,
  });

  final EntityId id;
  final String name;
  final DateTime date;
  final EntityId ownerId;
  final List<EntityId> memberIds;

  /// Display name of each member, written by the member itself: members
  /// cannot read each other's profile. Lists created before collaboration
  /// may miss some names.
  final Map<EntityId, String> memberNames;

  /// Token of the current invitation link, if one was shared.
  final String? inviteToken;
  final int itemCount;

  bool get isShared => memberIds.length > 1;

  bool isOwnedBy(EntityId uid) => ownerId == uid;

  String? nameOf(EntityId uid) => memberNames[uid];

  ShoppingList copyWith({String? name, DateTime? date}) => ShoppingList(
    id: id,
    name: name ?? this.name,
    date: date ?? this.date,
    ownerId: ownerId,
    memberIds: memberIds,
    memberNames: memberNames,
    inviteToken: inviteToken,
    itemCount: itemCount,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    date,
    ownerId,
    memberIds,
    memberNames,
    inviteToken,
    itemCount,
  ];
}
