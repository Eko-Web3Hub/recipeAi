import 'package:equatable/equatable.dart';
import 'package:recipe_ai/ddd/entity.dart';

class UserPersonnalInfo extends Equatable {
  final EntityId uid;
  final String email;
  final String name;

  const UserPersonnalInfo({
    required this.uid,
    required this.email,
    required this.name,
  });

  UserPersonnalInfo changeUsername(String username) {
    return _copyWith(name: username);
  }

  UserPersonnalInfo _copyWith({
    EntityId? uid,
    String? email,
    String? name,
  }) {
    return UserPersonnalInfo(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
    );
  }

  @override
  List<Object?> get props => [uid, email, name];
}
