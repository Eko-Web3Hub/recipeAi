import 'package:dio/dio.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe.dart';
import 'package:recipe_ai/receipe/domain/repositories/user_receipe_repository.dart';
import 'package:recipe_ai/receipe/infrastructure/serialization/receipe_api_serialization.dart';
import 'package:recipe_ai/utils/constant.dart';

class UserReceipeRepository implements IUserReceipeRepository {
  static const String baseUrl = "$baseApiUrl/gen-receipe-with-user-preference";

  final Dio _dio;

  UserReceipeRepository({required Dio dio}) : _dio = dio;

  @override
  Future<List<Receipe>> getReceipesBasedOnUserPreferencesFromApi(
      EntityId uid) async {
    final apiRoute = "$baseUrl/${uid.value}";
    final response = await _dio.get(apiRoute);
    final results = response.data["receipes"] as List;
    return results.map<Receipe>((receipe) => ReceipeApiSerialization.fromJson(receipe) ,).toList();
  }

  @override
  Future<UserReceipe> getReceipesBasedOnUserPreferencesFromFirestore(
      EntityId uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> save(EntityId uid, UserReceipe userReceipe) {
    throw UnimplementedError();
  }
}
