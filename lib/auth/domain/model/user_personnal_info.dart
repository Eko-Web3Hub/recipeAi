import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

class UserPersonnalInfo extends Equatable {
  final EntityId uid;
  final String name;

  const UserPersonnalInfo({
    required this.uid,
    required this.name,
  });

  UserPersonnalInfo changeUsername(String username) {
    return _copyWith(name: username);
  }

  static UserPersonnalInfo defaultInfo(EntityId uid, String name) =>
      UserPersonnalInfo(
        uid: uid,
        name: name,
      );

  UserPersonnalInfo _copyWith({
    EntityId? uid,
    String? name,
  }) {
    return UserPersonnalInfo(
      uid: uid ?? this.uid,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [uid, name];
}
