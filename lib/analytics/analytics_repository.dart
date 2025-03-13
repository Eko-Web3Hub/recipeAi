import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:recipe_ai/analytics/analytics_event.dart';

abstract class IAnalyticsRepository {
  Future<void> logEvent(AnalyticsEvent event);
}

class AnalyticsRepository implements IAnalyticsRepository {
  final FirebaseAnalytics _firebaseAnalytics;

  AnalyticsRepository(this._firebaseAnalytics);

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    await _firebaseAnalytics.logEvent(
      name: event.name,
      parameters: event.parameters,
    );
  }
}
