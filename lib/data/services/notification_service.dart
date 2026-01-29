import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static const String _appId = "9ebf990f-9e79-4915-823b-2f8346d221b2";

  static Future<void> initialize() async {
    // OneSignal does not support Web. Skip initialization on Web.
    if (kIsWeb) {
      debugPrint("OneSignal: Skipping initialization on Web platform.");
      return;
    }

    // Remove this log level for production
    if (kDebugMode) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    }

    OneSignal.initialize(_appId);

    // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);
  }

  static Future<void> setExternalUserId(String userId) async {
    if (kIsWeb) return;
    try {
      await OneSignal.login(userId);
    } catch (e) {
      debugPrint("Error setting OneSignal external user ID: $e");
    }
  }

  static Future<void> removeExternalUserId() async {
    if (kIsWeb) return;
    try {
      await OneSignal.logout();
    } catch (e) {
      debugPrint("Error removing OneSignal external user ID: $e");
    }
  }

  static Future<void> setTag(String key, dynamic value) async {
    if (kIsWeb) return;
    OneSignal.User.addTagWithKey(key, value.toString());
  }

  static Future<void> removeTag(String key) async {
    if (kIsWeb) return;
    OneSignal.User.removeTag(key);
  }
}
