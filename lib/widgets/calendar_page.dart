import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Appointment> appointments = [];
  MeetingDataSource? events;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.day,
        dataSource: events,
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            _showEventDetailsDialog(details.appointments![0]);
          } else if (details.targetElement == CalendarElement.calendarCell) {
            _showAddEventDialog(details.date!);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog(DateTime.now());
        },
        child: Icon(Icons.add),
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
    TextEditingController(text: '2'); // Default duration

    return showDialog(
      context: context,
      builder: (context) {
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
                    decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                  ),
                  SizedBox(height: 10.0),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(labelText: 'Time (HH:MM)'),
                  ),
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
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addEvent(
                  selectedDate,
                  titleController.text,
                  dateController.text,
                  timeController.text,
                  durationController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEventDetailsDialog(Appointment event) async {
    TextEditingController titleController = TextEditingController(text: event.subject);
    TextEditingController dateController = TextEditingController(text: formatDate(event.startTime));
    TextEditingController timeController = TextEditingController(text: formatTime(event.startTime));
    TextEditingController durationController = TextEditingController(text: (event.endTime.difference(event.startTime).inHours).toString());

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Event Details'),
          content: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Event Title',
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
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(labelText: 'Duration (hours)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _deleteEvent(event);
                      Navigator.of(context).pop();
                    },
                    child: Text('Delete'),
                  ),
                  SizedBox(width: 5.0),
                  ElevatedButton(
                    onPressed: () {
                      _editEvent(
                        event,
                        titleController.text,
                        dateController.text,
                        timeController.text,
                        durationController.text,
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                  SizedBox(width: 5.0)
                ],
              ),
            ),
          ],
        );
      },
    );
  }



  void _editEvent(
      Appointment event,
      String title,
      String date,
      String time,
      String duration,
      ) {
    setState(() {
      final DateTime newDateTime = DateTime.parse('$date $time');
      final DateTime startTime = DateTime(
        newDateTime.year,
        newDateTime.month,
        newDateTime.day,
        newDateTime.hour,
        newDateTime.minute,
      );

      // Calculate the duration dynamically
      final DateTime endTime = startTime.add(Duration(hours: int.parse(duration)));

      // Update the existing event details
      event.subject = title;
      event.startTime = startTime;
      event.endTime = endTime;

      events = MeetingDataSource(appointments);
    });
  }

  void _addEvent(
      DateTime selectedDate,
      String title,
      String date,
      String time,
      String duration,
      ) {
    setState(() {
      final DateTime newDateTime = DateTime.parse('$date $time');
      final DateTime startTime = DateTime(
        newDateTime.year,
        newDateTime.month,
        newDateTime.day,
        newDateTime.hour,
        newDateTime.minute,
      );
      final DateTime endTime =
      startTime.add(Duration(hours: int.parse(duration)));
      appointments.add(
        Appointment(
          startTime: startTime,
          endTime: endTime,
          subject: title,
          color: Colors.blue,
        ),
      );
      events = MeetingDataSource(appointments);
    });
  }

  void _deleteEvent(Appointment event) {
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

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }
}