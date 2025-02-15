import 'package:equatable/equatable.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserAccountMetaData extends Equatable {
  const UserAccountMetaData({
    required this.appLanguage,
  });

  final AppLanguage? appLanguage;

  @override
  List<Object?> get props => [appLanguage];
}
