import 'package:equatable/equatable.dart';

class UserPreference extends Equatable {
  final Map<String, dynamic> preferences;

  const UserPreference(this.preferences);

  @override
  List<Object?> get props => [preferences];
}
