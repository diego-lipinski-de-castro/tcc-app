import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';

class Logger {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics();

  static errorEvent(errorMessage) async {
    await _analytics.logEvent(name: 'google-signin-error', parameters: {
        'message': errorMessage.toString(),
        'environment': Platform.environment.toString(),
        'operatingSystem': Platform.operatingSystem.toString(),
        'localeName': Platform.localeName.toString(),
        'localHostname': Platform.localHostname.toString(),
        'operatingSystemVersion': Platform.operatingSystemVersion.toString(),
        'packageConfig': Platform.packageConfig.toString(),
        'version': Platform.version.toString()
      });
  }
}