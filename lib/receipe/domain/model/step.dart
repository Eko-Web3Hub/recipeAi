import 'package:equatable/equatable.dart';

class ReceipeStep extends Equatable {
  final String description;
  final String? duration;

  const ReceipeStep({
    required this.description,
    required this.duration,
  });

  @override
  List<Object?> get props => [description, duration];
}
