import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ================= INIT =================
  Future<void> init() async {
    // 1. Init timezone
    tz.initializeTimeZones();
    // FIX cứng timezone VN
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // 2. Android settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: android);

    // 3. Init plugin
    await _plugin.initialize(settings);

    // 4. Xin quyền notification
    await _requestPermission();
  }

  // ================= REQUEST PERMISSION =================
  Future<void> _requestPermission() async {
    var status = await Permission.notification.status;

    if (status.isDenied) {
      await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  static AndroidNotificationDetails _createAndroidDetails({
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

  // Hàm tái sử dụng cho thiết lập thời gian để bật notification zonedSchedule
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationDetails androidDetails,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,// exact: thong bao thoi gian chinh xac; inexact: thong bao tgian co the tre 1,2phut nhung kh can cap quyen
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Hàm gửi thông báo tức thì
  Future<void> showSimpleNotification({
    int id = 0,
    String title = 'Nhắc học từ vựng',
    String body = 'Bạn đã học 5 từ mới hôm nay chưa?',
  }) async {
    final details = _createAndroidDetails(
      channelId: 'learn_english_channel',
      channelName: 'Học Anh Văn',
    );
    await _plugin.show(id, title, body, NotificationDetails(android: details));
  }

  /// Đặt lịch sau 1 khoảng thời gian delay
  Future<void> scheduleNotificationAfter(
    Duration delay, 
    String channelId,
    String channelName,
    String channelDescription,
  ) async {
    final details = _createAndroidDetails(
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDescription,
    );
    final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
    await _scheduleNotification(
      id: 1,
      title: channelName,
      body: channelDescription,
      scheduledTime: scheduledTime,
      androidDetails: details,
    );
  }
}
