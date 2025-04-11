import 'package:equatable/equatable.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserAccountMetaData extends Equatable {
  const UserAccountMetaData({
    required this.appLanguage,
  });

  final AppLanguage appLanguage;

  Map<String, dynamic> toJson() {
    return {
      'appLanguage': appLanguage.name,
    };
  }

  factory UserAccountMetaData.fromJson(Map<String, dynamic> json) {
    final appLanguage = json['appLanguage'] as String;

    return UserAccountMetaData(
      appLanguage: appLanguageFromString(appLanguage),
    );
  }

  UserAccountMetaData changeLanguage(
    AppLanguage appLanguage,
  ) {
    assert(appLanguage != this.appLanguage);

    return _copyWith(
      appLanguage: appLanguage,
    );
  }

  UserAccountMetaData _copyWith({
    AppLanguage? appLanguage,
  }) {
    return UserAccountMetaData(
      appLanguage: appLanguage ?? this.appLanguage,
    );
  }

  @override
  List<Object?> get props => [appLanguage];
}
