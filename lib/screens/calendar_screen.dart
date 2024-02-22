import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../model/Course.dart';
import '../widgets/weather_widget.dart';
import 'event_screen.dart';

import '../model/CalendarEvent.dart';
import '../model/Professor.dart';
import '../model/Room.dart';
import '../service/CalendarEventService.dart';
import '../service/NotificationsService.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<CalendarEvent> appointments = [];
  MeetingDataSource? events;
  final CalendarEventService firestoreService = CalendarEventService();
  final NotificationsService notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _loadEventsForCurrentDay(DateTime.now());
  }

  Future<void> _loadEventsForCurrentDay(DateTime date) async {
    String formattedDate = formatDate(date);
    List<CalendarEvent> eventsForCurrentDay =
    await firestoreService.getEventsForDay(formattedDate);

    setState(() {
      appointments = eventsForCurrentDay;
      events = MeetingDataSource(appointments);
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Calendar App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Calendar'),
          actions: [
            WeatherWidget(),
          ],
        ),
        body: Stack(
          children: [
            SfCalendar(
              view: CalendarView.day,
              dataSource: events,
              onTap: (CalendarTapDetails details) {
                if (details.appointments != null &&
                    details.appointments!.isNotEmpty) {
                  _showEventDetailsDialog(details.appointments![0]);
                } else if (details.targetElement ==
                    CalendarElement.calendarCell) {
                  _showAddEventDialog(details.date!);
                }
              },
              onViewChanged: (ViewChangedDetails details) {
                _loadEventsForCurrentDay(details.visibleDates[0]);
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showAddEventDialog(DateTime.now());
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> _showAddEventDialog(DateTime selectedDate) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController dateController =
    TextEditingController(text: formatDate(selectedDate));
    TextEditingController timeController =
    TextEditingController(text: formatTime(selectedDate));
    TextEditingController durationController =
    TextEditingController(text: '2');

    Course? selectedCourse;

    return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Course>>(
          future: _fetchAvailableCourses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Course> courses = snapshot.data!;

              return AlertDialog(
                title: Text('Add Event'),
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
                          decoration:
                          InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                        ),
                        SizedBox(height: 10.0),
                        TextField(
                          controller: timeController,
                          decoration: InputDecoration(labelText: 'Time (HH:MM)'),
                        ),
                        TextField(
                          controller: durationController,
                          decoration:
                          InputDecoration(labelText: 'Duration (hours)'),
                        ),
                        SizedBox(height: 10.0),
                        DropdownButtonFormField<Course>(
                          hint: Text('Select a Course'),
                          value: selectedCourse,
                          items: courses.map<DropdownMenuItem<Course>>((Course course) {
                            return DropdownMenuItem<Course>(
                              value: course,
                              child: Text(course.courseName),
                            );
                          }).toList(),
                          onChanged: (Course? newValue) {
                            setState(() {
                              selectedCourse = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedCourse != null) {
                        await _addEvent(
                          selectedDate,
                          titleController.text,
                          dateController.text,
                          timeController.text,
                          durationController.text,
                          selectedCourse!,
                        );
                        Navigator.of(context).pop();
                      } else {
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }


  Future<void> _showEventDetailsDialog(CalendarEvent event) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventScreen(
            event: event, onDelete: _deleteEvent, onEdit: _editEvent),
      ),
    );
  }

  Future<void> _addEvent(
      DateTime selectedDate,
      String title,
      String date,
      String time,
      String duration,
      Course selectedCourse,
      ) async {
    final DateTime newDateTime = DateTime.parse('$date $time');
    final DateTime startTime = DateTime(
      newDateTime.year,
      newDateTime.month,
      newDateTime.day,
      newDateTime.hour,
      newDateTime.minute,
    );
    final DateTime endTime = startTime.add(Duration(hours: int.parse(duration)));

    final newEvent = CalendarEvent.autogenerated(
      title: title,
      description: '',
      professor: Professor(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
      ),
      room: Room(
        id: '215',
        name: 'Room 215',
        building: 'Main Building',
        floor: '1',
        seats: [1, 2, 3, 4],
      ),
      startTime: startTime,
      endTime: endTime,
      course: selectedCourse,
    );

    await firestoreService.saveCalendarEvent(newEvent);
    setState(() {
      appointments.add(newEvent);
      events = MeetingDataSource(appointments);
    });
    await notificationsService.scheduleEventNotification(newEvent.startTime, newEvent.title);
  }


  Future<void> _editEvent(
      CalendarEvent event,
      String title,
      String date,
      String time,
      String duration,
      Course selectedCourse,
      ) async {
    final DateTime newDateTime = DateTime.parse('$date $time');
    final DateTime startTime = DateTime(
      newDateTime.year,
      newDateTime.month,
      newDateTime.day,
      newDateTime.hour,
      newDateTime.minute,
    );
    final DateTime endTime = startTime.add(Duration(hours: int.parse(duration)));

    final editedEvent = CalendarEvent(
      id: event.id,
      title: title,
      description: '',
      professor: Professor(
        id: '1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
      ),
      room: Room(
        id: 'A101',
        name: 'Room A101',
        building: 'Main Building',
        floor: '1',
        seats: [1, 2, 3, 4],
      ),
      startTime: startTime,
      endTime: endTime,
      course: selectedCourse,
    );

    await firestoreService.updateCalendarEvent(editedEvent);
    setState(() {
      event.subject = title;
      event.startTime = startTime;
      event.endTime = endTime;
      events = MeetingDataSource(appointments);
    });
    await notificationsService.scheduleEventNotification(event.startTime, event.title);
  }


  Future<void> _deleteEvent(CalendarEvent event) async {
    await firestoreService.deleteCalendarEvent(event.id);
    setState(() {
      appointments.remove(event);
      events = MeetingDataSource(appointments);
    });
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

Future<List<Course>> _fetchAvailableCourses() async {
  try {
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('courses').get();

    List<Course> courses = querySnapshot.docs.map((DocumentSnapshot document) {
      return Course(
        courseId: document.id,
        courseName: document['courseName'] ?? '',
        courseFullName: document['courseFullName'] ?? ''
      );
    }).toList();

    return courses;
  } catch (error) {
    print('Error fetching courses: $error');
    throw error;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<CalendarEvent> source) {
    appointments = source;
  }
}
