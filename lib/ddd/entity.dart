import 'package:equatable/equatable.dart';

class EntityId with EquatableMixin {
  const EntityId(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}
