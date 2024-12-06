import 'package:equatable/equatable.dart';

enum UserPreferenceQuestionType {
  multipleChoice,
}

UserPreferenceQuestionType userPreferenceQuestionTypeFromString(String type) {
  switch (type) {
    case 'multiple-choice':
      return UserPreferenceQuestionType.multipleChoice;
    default:
      throw UnimplementedError();
  }
}

abstract class UserPreferenceQuestion extends Equatable {
  final String title;
  final String description;
  final UserPreferenceQuestionType type;

  const UserPreferenceQuestion({
    required this.title,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [title, description, type];
}

class UserPreferenceQuestionMultipleChoice extends UserPreferenceQuestion {
  final List<String> options;

  UserPreferenceQuestionMultipleChoice({
    required super.title,
    required super.description,
    required super.type,
    required this.options,
  });

  factory UserPreferenceQuestionMultipleChoice.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserPreferenceQuestionMultipleChoice(
      title: json['title'] as String,
      description: json['description'] as String,
      type: userPreferenceQuestionTypeFromString(json['type'] as String),
      options: (json['options'] as List).cast<String>(),
    );
  }

  void answer(String option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
      return;
    }

    selectedOptions.add(option);
  }

  List<String> get retrieveSelectedOptions => selectedOptions;

  @override
  List<Object?> get props => [...super.props, options, type];

  final List<String> selectedOptions = [];
}
