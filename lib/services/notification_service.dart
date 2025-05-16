import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:appdev2/main.dart';
import 'package:appdev2/Admin/AdminNotifications.dart';
import 'package:appdev2/Employee/EmployeeNotifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appdev2/login.dart';

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
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Scheduled notification channel',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
    );

    // Set up notification action listener
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction action) async {
        // Get current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          // Redirect to login page immediately
          MyApp.navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
          return;
        }
        // Check if user is admin or employee
        final email = user.email;
        final adminSnapshot = await FirebaseFirestore.instance.collection('Admins').where('email', isEqualTo: email).get();
        final isAdmin = adminSnapshot.docs.isNotEmpty;
        if (isAdmin) {
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => AdminNotifications()),
          );
        } else {
          MyApp.navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (context) => EmployeeNotifications(userEmail: email ?? '')),
          );
        }
      },
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationLayout layout = NotificationLayout.Default,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        payload: {'data': payload ?? ''},
        notificationLayout: layout,
      ),
    );
  }

  Future<void> showScheduledNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'scheduled_channel',
        title: title,
        body: body,
        payload: {'data': payload ?? ''},
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
} 