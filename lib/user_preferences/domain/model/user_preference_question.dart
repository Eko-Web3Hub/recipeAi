import 'package:equatable/equatable.dart';

enum UserPreferenceQuestionType {
  multipleChoice,
}

UserPreferenceQuestionType userPreferenceQuestionTypeFromString(String type) {
  switch (type) {
    case 'multipleChoice':
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

  Map<String, dynamic> toJson();

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

  bool isOptionSelected(String option) => selectedOptions.contains(option);

  @override
  List<Object?> get props => [...super.props, options];

  final List<String> selectedOptions = [];

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    for (final option in options) {
      json[option] = selectedOptions.contains(option);
    }

    return json;
  }
}
