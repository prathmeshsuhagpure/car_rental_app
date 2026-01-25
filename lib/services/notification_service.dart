import 'package:car_rent_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';


Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final ApiService _apiService = ApiService();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  List<NotificationItem> _notifications = [];
  Function(List<NotificationItem>)? _onNotificationsChanged;
  Function(NotificationItem)? _onNotificationOpened;

  String? get fcmToken => _fcmToken;
  List<NotificationItem> get notifications => _notifications;

  void setNotificationsChangedCallback(Function(List<NotificationItem>) callback) {
    _onNotificationsChanged = callback;
  }

  void setNotificationOpenedCallback(Function(NotificationItem) callback) {
    _onNotificationOpened = callback;
  }

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ Notification permission granted');
    }

    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@drawable/ic_notification');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(initSettings, onDidReceiveNotificationResponse: _onNotificationTapped);

    _fcmToken = await _firebaseMessaging.getToken();
    if (_fcmToken != null) {
      await _apiService.sendFCMTokenToBackend(_fcmToken!);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await _apiService.sendFCMTokenToBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _handleForegroundMessage(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationOpened(message);
    });

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpened(initialMessage);
    }

    await _firebaseMessaging.subscribeToTopic('dailydrive_notifications');
    await _loadStoredNotifications();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = _createNotificationFromMessage(message);
    _notifications.insert(0, notification);
    _saveNotifications();
    _showLocalNotification(message);
    _onNotificationsChanged?.call(_notifications);
  }

  void _handleNotificationOpened(RemoteMessage message) {
    final notification = _createNotificationFromMessage(message);
    notification.isNew = false;

    if (!_notifications.any((n) => n.id == notification.id)) {
      _notifications.insert(0, notification);
      _saveNotifications();
      _onNotificationsChanged?.call(_notifications);
    }
    _onNotificationOpened?.call(notification);
  }

  NotificationItem _createNotificationFromMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    return NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ?? data['title'] ?? 'New Notification',
      subtitle: notification?.body ?? data['body'] ?? 'You have a new message',
      time: _getTimeAgo(DateTime.now()),
      icon: _getIconFromType(data['type'] ?? 'general'),
      color: _getColorFromType(data['type'] ?? 'general'),
      isNew: true,
      type: data['type'] ?? 'general',
      payload: data,
    );
  }

  IconData _getIconFromType(String type) {
    switch (type.toLowerCase()) {
      case 'ride':
      case 'booking':
        return Icons.directions_car;
      case 'payment':
        return Icons.payment;
      case 'rating':
      case 'feedback':
        return Icons.star_rate;
      case 'offer':
      case 'promotion':
        return Icons.local_offer;
      case 'profile':
        return Icons.person;
      case 'alert':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorFromType(String type) {
    switch (type.toLowerCase()) {
      case 'ride':
      case 'booking':
        return Color(0xFF2E7D32);
      case 'payment':
        return Color(0xFF1976D2);
      case 'rating':
      case 'feedback':
        return Color(0xFFFF9800);
      case 'offer':
      case 'promotion':
        return Color(0xFFE91E63);
      case 'profile':
        return Color(0xFF9C27B0);
      case 'alert':
        return Color(0xFFF44336);
      default:
        return Color(0xFF607D8B);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'dailydrive_channel',
      'DailyDrive Notifications',
      channelDescription: 'Notifications for DailyDrive app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      jsonDecode(response.payload!);
    }
  }

  Future<void> _loadStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getStringList('notifications') ?? [];
    _notifications = notificationsJson.map((json) => NotificationItem.fromJson(jsonDecode(json))).toList();
    _onNotificationsChanged?.call(_notifications);
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList('notifications', notificationsJson);
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    _onNotificationsChanged?.call(_notifications);
  }

  Future<void> markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isNew = false;
    }
    await _saveNotifications();
    _onNotificationsChanged?.call(_notifications);
  }

  Future<void> markAsRead(NotificationItem notification) async {
    notification.isNew = false;
    await _saveNotifications();
    _onNotificationsChanged?.call(_notifications);
  }

  int get newNotificationsCount => _notifications.where((n) => n.isNew).length;
}