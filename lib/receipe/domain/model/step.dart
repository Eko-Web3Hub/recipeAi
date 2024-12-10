import 'package:equatable/equatable.dart';

class Step extends Equatable {
  final String description;
  final String? duration;

  const Step({
    required this.description,
    required this.duration,
  });

  @override
  List<Object?> get props => [description, duration];
}
