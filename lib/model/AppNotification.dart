import 'package:uuid/uuid.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime dateTime;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.dateTime,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? _generateId(),
      title: json['title'],
      body: json['body'],
      dateTime: DateTime.parse(json['dateTime'] ?? ''),
    );
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      dateTime: DateTime.parse(map['dateTime'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  static String _generateId() {
    final uuid = Uuid();
    return uuid.v4();
  }
}