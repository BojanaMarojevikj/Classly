import 'package:classly/model/CalendarEvent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/Course.dart';

class EventScreen extends StatefulWidget {
  final CalendarEvent event;
  final Function(CalendarEvent) onDelete;
  final Function(CalendarEvent, String, String, String, String, Course) onEdit;

  EventScreen({required this.event, required this.onDelete, required this.onEdit});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  List<Course> _availableCourses = [];
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _selectedCourse = widget.event.course;
    _fetchAvailableCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _editEvent(context, _availableCourses, widget.event, _selectedCourse);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event Title: ${widget.event.subject}'),
            SizedBox(height: 10.0),
            Text('Date: ${formatDate(widget.event.startTime)}'),
            SizedBox(height: 10.0),
            Text('Time: ${formatTime(widget.event.startTime)}'),
            SizedBox(height: 10.0),
            Text('Duration: ${widget.event.endTime.difference(widget.event.startTime).inHours} hours'),
            SizedBox(height: 10.0),
            if (_selectedCourse != null)
              Text('Course: ${_selectedCourse!.courseName}'),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _deleteEvent(context);
              },
              child: Text('Delete Event'),
            ),
          ],
        ),
      ),
    );
  }


  void _deleteEvent(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Event'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDelete(widget.event);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _editEvent(BuildContext context, List<Course> availableCourses, CalendarEvent event, Course? selectedCourse) {
    TextEditingController titleController = TextEditingController(text: event.subject);
    TextEditingController dateController = TextEditingController(text: formatDate(event.startTime));
    TextEditingController timeController = TextEditingController(text: formatTime(event.startTime));
    TextEditingController durationController = TextEditingController(text: event.endTime.difference(event.startTime).inHours.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Event'),
          content: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Enter event title',
                    ),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(labelText: 'Time (HH:MM)'),
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField<Course>(
                    value: _selectedCourse,
                    items: availableCourses.map((Course course) {
                      return DropdownMenuItem<Course>(
                        value: course,
                        child: Text(course.courseName),
                      );
                    }).toList(),
                    onChanged: (Course? newValue) {
                      setState(() {
                        _selectedCourse = newValue;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(labelText: 'Duration (hours)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onEdit(
                  event,
                  titleController.text,
                  dateController.text,
                  timeController.text,
                  durationController.text,
                  selectedCourse!,
                );
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }



  void _fetchAvailableCourses() {
    FirebaseFirestore.instance.collection('courses').get().then((
        QuerySnapshot querySnapshot,
        ) {
      List<Course> courses = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Course course = Course(
          courseId: document.id,
          courseName: document['courseName'] ?? '',
            courseFullName: document['courseFullName'] ?? ''
        );
        courses.add(course);
      });

      setState(() {
        _availableCourses = courses;
      });
    }).catchError((error) {
      print('Error fetching courses: $error');
    });
  }


  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}