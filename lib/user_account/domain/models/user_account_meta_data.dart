import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserAccountMetaData extends Equatable {
  const UserAccountMetaData({
    required this.appLanguage,
    required this.lastLogin,
  });

  final AppLanguage appLanguage;
  final DateTime? lastLogin;

  Map<String, dynamic> toJson() {
    return {
      'appLanguage': appLanguage.name,
      'lastLogin': lastLogin,
    };
  }

  factory UserAccountMetaData.fromJson(Map<String, dynamic> json) {
    final appLanguage = json['appLanguage'] as String;
    final lastLogin = json['lastLogin'] as Timestamp?;

    return UserAccountMetaData(
      appLanguage: appLanguageFromString(appLanguage),
      lastLogin: lastLogin?.toDate(),
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

  UserAccountMetaData updateLastLogin(DateTime lastLogin) {
    return _copyWith(
      lastLogin: lastLogin,
    );
  }

  UserAccountMetaData _copyWith({
    AppLanguage? appLanguage,
    DateTime? lastLogin,
  }) {
    return UserAccountMetaData(
      appLanguage: appLanguage ?? this.appLanguage,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  List<Object?> get props => [appLanguage];
}
