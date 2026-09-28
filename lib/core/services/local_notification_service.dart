import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract final class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _budgetChannelId = 'pennypal_budget_alerts';
  static const String _budgetChannelName = 'Budget & Spending Alerts';
  static const String _budgetChannelDesc =
      'Alerts for budget threshold crossings and spending limits.';

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    try {
      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _budgetChannelId,
            _budgetChannelName,
            description: _budgetChannelDesc,
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Failed to initialize local notifications: $e');
    }
  }

  static Future<bool> requestPermissions() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
    return false;
  }

  static Future<void> showNotification({
    int id = 1,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const androidDetails = AndroidNotificationDetails(
      _budgetChannelId,
      _budgetChannelName,
      channelDescription: _budgetChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'PennyPal Alert',
      enableVibration: true,
      playSound: true,
      color: Color(0xFF4F46E5),
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Could not display notification: $e');
    }
  }

  static Future<void> showBudgetAlert({
    required String category,
    required double percentSpent,
    required double limit,
    bool isOver = false,
  }) async {
    final title = isOver ? '⚠️ Over Budget Alert!' : '⚡ Budget Alert (80%)';
    final body = isOver
        ? 'You have exceeded your $category budget limit of Rs. ${limit.toInt()}!'
        : 'You have used ${(percentSpent * 100).toInt()}% of your $category budget.';

    await showNotification(
      id: category.hashCode,
      title: title,
      body: body,
      payload: 'budget_alert',
    );
  }

  static Future<void> showSavingsMilestone({
    required String goalName,
    required int milestone,
  }) async {
    await showNotification(
      id: goalName.hashCode,
      title: '🎉 Goal Milestone Unlocked!',
      body:
          'Congratulations! You reached $milestone% of your "$goalName" savings goal!',
      payload: 'savings_milestone',
    );
  }
}
