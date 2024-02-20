import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsService {
  final CollectionReference notificationsCollection =
  FirebaseFirestore.instance.collection('notifications');

  Future<void> saveNotification({
    required String id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await notificationsCollection.doc(id).set({
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime,
    });
  }


  Future<void> scheduleEventNotification(
      DateTime eventDate, String eventTitle) async {
    if (eventDate
        .subtract(const Duration(days: 1))
        .isBefore(DateTime.now())) {
      return;
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'classly1',
      'classly_notifications',
      channelDescription: 'classly notifications',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID for the notification
      'Event Reminder',
      'You have a class tomorrow!',
      tz.TZDateTime.from(
        eventDate.subtract(const Duration(days: 1)),
        tz.getLocation("Europe/Skopje"),
      ),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<List<Map<String, dynamic>>> getNotificationsFromFirebase() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('notifications').get();

      List<Map<String, dynamic>> notifications = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return notifications;
    } catch (error) {
      print('Error fetching notifications from Firebase: $error');
      throw error;
    }
  }
}