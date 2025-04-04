abstract class AnalyticsEvent {
  AnalyticsEvent(
    this.parameters,
  );

  String get name;
  final Map<String, Object>? parameters;
}

class OnboardingStartedEvent extends AnalyticsEvent {
  OnboardingStartedEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'onboarding_started';
}

class OnboardingCompletedEvent extends AnalyticsEvent {
  OnboardingCompletedEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'onboarding_completed';
}

class LoginStartEvent extends AnalyticsEvent {
  LoginStartEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'login_start';
}

class LoginFinishEvent extends AnalyticsEvent {
  LoginFinishEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'login_finish';
}

class RegisterStartEvent extends AnalyticsEvent {
  RegisterStartEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'register_start';
}

class RegisterFinishEvent extends AnalyticsEvent {
  RegisterFinishEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'register_finish';
}

class RecipeSeenEvent extends AnalyticsEvent {
  RecipeSeenEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_seen';
}

class TicketScanSuccessEvent extends AnalyticsEvent {
  TicketScanSuccessEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'ticket_scan_success';
}

class TicketScanErrorEvent extends AnalyticsEvent {
  TicketScanErrorEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'ticket_scan_error';
}

class RecipeSavedEvent extends AnalyticsEvent {
  RecipeSavedEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_saved';
}

class RecipeGenerateUsingIngredientListSavedEvent extends AnalyticsEvent {
  RecipeGenerateUsingIngredientListSavedEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_generate_using_ingredient_list_saved';
}

class RecipeGenerateUsingIngredientListUnSavedEvent extends AnalyticsEvent {
  RecipeGenerateUsingIngredientListUnSavedEvent(
      {Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_generate_using_ingredient_list_unsaved';
}

class RecipeGenerateUsingIngredientPictureSavedEvent extends AnalyticsEvent {
  RecipeGenerateUsingIngredientPictureSavedEvent(
      {Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_generate_using_ingredient_picture_saved';
}

class RecipeGenerateUsingIngredientPictureUnSavedEvent extends AnalyticsEvent {
  RecipeGenerateUsingIngredientPictureUnSavedEvent(
      {Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_generate_using_ingredient_picture_unsaved';
}

class RecipeUnSaveEvent extends AnalyticsEvent {
  RecipeUnSaveEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'recipe_unsave';
}

class IngredientManuallyAddedEvent extends AnalyticsEvent {
  IngredientManuallyAddedEvent({Map<String, Object>? parameters})
      : super(
          parameters,
        );

  @override
  String get name => 'ingredient_manually_added';
}
