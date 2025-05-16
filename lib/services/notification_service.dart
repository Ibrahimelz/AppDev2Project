import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // null means use default app icon
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Basic notification channel',
          defaultColor: Colors.orangeAccent,
          ledColor: Colors.orangeAccent,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
    );

    // Set up notification action listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: {'data': payload ?? ''},
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification action
    if (receivedAction.payload != null) {
      // You can add custom logic here to handle the notification action
      debugPrint('Notification action received: ${receivedAction.payload}');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification creation
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Handle notification display
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification dismissal
    debugPrint('Notification dismissed: ${receivedAction.title}');
  }
} 