import 'package:equatable/equatable.dart';
import 'package:recipe_ai/user_preferences/domain/model/user_preference.dart';

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

  UserPreferenceQuestion initWithUserPreference(UserPreference userPreference);

  @override
  List<Object?> get props => [title, description, type];
}

class UserPreferenceQuestionMultipleChoice extends UserPreferenceQuestion {
  final List<Option> options;

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
      options: (json['options'] as List)
          .map((option) => Option.fromJson(option))
          .toList(),
    );
  }

  void answer(String option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
      return;
    }

    selectedOptions.add(option);
  }

  bool isOptionSelected(String option) => selectedOptions.contains(option);

  @override
  UserPreferenceQuestionMultipleChoice initWithUserPreference(
    UserPreference userPreference,
  ) {
    final preferences = userPreference.preferences;
    final currentSelectedOptions = <String>[];

    currentSelectedOptions.addAll(
      options
          .where((option) => preferences[option.key] == true)
          .map((e) => e.key),
    );
    final newQuestion = copyWith();
    for (final option in currentSelectedOptions) {
      newQuestion.answer(option);
    }

    return newQuestion;
  }

  UserPreferenceQuestionMultipleChoice copyWith({
    String? title,
    String? description,
    List<Option>? options,
  }) {
    return UserPreferenceQuestionMultipleChoice(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type,
      options: options ?? this.options,
    );
  }

  @override
  List<Object?> get props => [...super.props, options];

  final List<String> selectedOptions = [];

  @override
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    for (final option in options) {
      json[option.key] = selectedOptions.contains(option.key);
    }

    return json;
  }
}

class Option extends Equatable {
  final String label;
  final String key;

  const Option({
    required this.label,
    required this.key,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      label: json['label'] as String,
      key: json['key'] as String,
    );
  }

  @override
  List<Object?> get props => [label, key];
}
