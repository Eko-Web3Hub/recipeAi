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
