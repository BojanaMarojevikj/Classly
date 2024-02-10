import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/CalendarEvent.dart';

class FirestoreService {
  final CollectionReference calendarEventsCollection =
  FirebaseFirestore.instance.collection('calendar_events');

  Future<void> saveCalendarEvent(CalendarEvent event) async {
    try {
      await calendarEventsCollection.doc(event.id).set({
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'professor': {
          'id': event.professor.id,
          'firstName': event.professor.firstName,
          'lastName': event.professor.lastName,
          'email': event.professor.email,
        },
        'room': {
          'id': event.room.id,
          'name': event.room.name,
          'building': event.room.building,
          'floor': event.room.floor,
          'seats': event.room.seats,
        },
        'startTime': event.startTime,
        'endTime': event.endTime,
      });
    } catch (e) {
      print('Firestore Error: $e');
    }
  }
}
