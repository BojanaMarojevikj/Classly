import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../model/CalendarEvent.dart';
import '../model/Professor.dart';
import '../model/Room.dart';

class FirestoreService {
  final CollectionReference calendarEventsCollection =
  FirebaseFirestore.instance.collection('calendar_events');

  Future<void> saveCalendarEvent(CalendarEvent event) async {
    await calendarEventsCollection.doc(event.id).set({
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
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    await calendarEventsCollection.doc(eventId).delete();
  }

  Future<void> updateCalendarEvent(CalendarEvent event) async {
    await calendarEventsCollection.doc(event.id).update({
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
  }
}
