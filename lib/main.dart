import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
          if (details.targetElement == CalendarElement.calendarCell) {
            _showAddEventDialog(details.date!);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Optionally, you can provide a default date for the floating button.
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
