import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/ddd/entity.dart';
import 'package:recipe_ai/home/presentation/receipe_item_controller.dart';
import 'package:recipe_ai/receipe/application/user_recipe_service.dart';
import 'package:recipe_ai/receipe/domain/model/receipe.dart';
import 'package:recipe_ai/receipe/domain/model/user_receipe_v2.dart';

class UserRecipeServiceMock extends Mock implements IUserRecipeService {}

class AnalyticsRepositoryMock extends Mock implements IAnalyticsRepository {}

void main() {
  late IUserRecipeService userRecipeService;
  late IAnalyticsRepository analyticsRepository;

  const receipe = Receipe(
      name: "name",
      ingredients: [],
      steps: [],
      averageTime: "",
      totalCalories: "");

  final userRecipe = UserRecipeV2(
    id: const EntityId('recipeId'),
    receipeFr: receipe,
    receipeEn: receipe,
    createdDate: DateTime(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(RecipeSavedEvent());
  });

  setUp(
    () {
      userRecipeService = UserRecipeServiceMock();
      analyticsRepository = AnalyticsRepositoryMock();

      when(() => analyticsRepository.logEvent(any())).thenAnswer(
        (_) => Future.value(),
      );
    },
  );

  ReceipeItemController buildSut() {
    return ReceipeItemController(
      userRecipe,
      userRecipeService,
      analyticsRepository,
    );
  }

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should be in unsaved state when not saved",
    build: () => buildSut(),
    setUp: () {
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(false));
    },
    verify: (bloc) =>
        expect(bloc.state, equals(const ReceipeItemStateUnsaved())),
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should be in saved state when already saved",
    build: () => buildSut(),
    setUp: () {
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(true));
    },
    verify: (bloc) => expect(bloc.state, equals(const ReceipeItemStateSaved())),
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should save receipe",
    build: () => buildSut(),
    setUp: () {
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(false));
      when(() => userRecipeService.addToFavorite(userRecipe))
          .thenAnswer((_) => Future.value());
    },
    act: (bloc) async {
      await pumpEventQueue();
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(true));
      bloc.toggleFavorite();
    },
    verify: (bloc) => {
      verify(() => userRecipeService.addToFavorite(userRecipe)).called(1),
      expect(bloc.state, equals(const ReceipeItemStateSaved())),
    },
  );

  //should emit exception when saving fails
  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should emit error when saving fails",
    build: () => buildSut(),
    setUp: () {
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(false));
      when(() => userRecipeService.addToFavorite(userRecipe))
          .thenThrow(Exception());
    },
    act: (bloc) async {
      await pumpEventQueue();
      bloc.toggleFavorite();
    },
    verify: (bloc) => {
      expect(bloc.state,
          equals(const ReceipeItemStateError("Error saving receipe")))
    },
  );

  //should emit error when remove receipe failed
  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should emit error when removing fails",
    build: () => buildSut(),
    setUp: () {
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(true));
      when(() => userRecipeService.removeFromFavorite(userRecipe))
          .thenThrow(Exception());
    },
    act: (bloc) async {
      await pumpEventQueue();
      bloc.toggleFavorite();
    },
    verify: (bloc) => {
      expect(bloc.state,
          equals(const ReceipeItemStateError("Error removing saved receipe")))
    },
  );

  blocTest<ReceipeItemController, ReceipeItemState>(
    "Should remove saved receipe",
    build: () => buildSut(),
    setUp: () {
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(true));
      when(() => userRecipeService.removeFromFavorite(userRecipe))
          .thenAnswer((_) => Future.value());
    },
    act: (bloc) async {
      await pumpEventQueue();
      when(() => userRecipeService.isReceiptSaved(userRecipe.id!))
          .thenAnswer((_) => Stream.value(false));
      bloc.toggleFavorite();
    },
    verify: (bloc) => {
      verify(() => userRecipeService.removeFromFavorite(userRecipe)).called(1),
      expect(bloc.state, equals(const ReceipeItemStateUnsaved()))
    },
  );
}
