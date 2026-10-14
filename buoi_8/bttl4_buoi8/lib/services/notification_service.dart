import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    await _requestPermission();

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.status;

    if (status.isDenied || status.isRestricted || status.isLimited) {
      await Permission.notification.request();
    }

    final newStatus = await Permission.notification.status;

    if (newStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  static AndroidNotificationDetails _androidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
  }

  int _createId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
  }

  Future<void> showSimpleNotification({
    int? id,
    required String title,
    required String body,
    String channelId = 'default_channel',
    String channelName = 'Default',
    String? channelDescription,
  }) async {
    await init();

    final details = _androidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    await _plugin.show(
      id ?? _createId(),
      title,
      body,
      NotificationDetails(android: details),
    );
  }

  Future<int> scheduleNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) async {
    await init();

    final notificationId = id ?? _createId();

    DateTime time = scheduledTime;

    if (time.isBefore(DateTime.now())) {
      time = DateTime.now().add(const Duration(seconds: 3));
    }

    final details = _androidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );

    Future<void> doSchedule(AndroidScheduleMode mode) {
      return _plugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(time, tz.local),
        NotificationDetails(android: details),
        androidScheduleMode: mode,
      );
    }

    try {
      await doSchedule(AndroidScheduleMode.exactAllowWhileIdle);
    } catch (_) {
      await doSchedule(AndroidScheduleMode.inexactAllowWhileIdle);
    }

    return notificationId;
  }

  Future<int> scheduleNotificationAfter({
    int? id,
    required Duration delay,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: DateTime.now().add(delay),
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );
  }

  Future<List<PendingNotificationRequest>> pendingNotifications() async {
    await init();
    return _plugin.pendingNotificationRequests();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}