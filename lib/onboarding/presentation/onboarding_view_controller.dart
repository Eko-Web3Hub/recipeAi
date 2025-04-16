import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';
import 'package:recipe_ai/analytics/analytics_repository.dart';
import 'package:recipe_ai/utils/local_storage_repo.dart';

abstract class OnboardingState extends Equatable {}

class OnboardingRequired extends OnboardingState {
  @override
  List<Object?> get props => [];
}

class OnboardingCompleted extends OnboardingState {
  @override
  List<Object?> get props => [];
}

class OnboardingController extends Cubit<OnboardingState?> {
  static const _hasSeenOnboardingKey = 'has_already_seen_onboarding';
  final ILocalStorageRepository _prefs;
  final IAnalyticsRepository _analyticsRepository;

  OnboardingController(this._prefs, this._analyticsRepository) : super(null);

  Future<void> completeOnboarding() async {
    _analyticsRepository.logEvent(
      OnboardingCompletedEvent(),
    );
    await _prefs.setBool(_hasSeenOnboardingKey, true);
    emit(OnboardingCompleted());
    emit(null);
  }
}
