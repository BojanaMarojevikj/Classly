import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../model/CalendarEvent.dart';

class EditEventScreen extends StatefulWidget {
  final Appointment event;

  EditEventScreen({required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.subject);
    startTimeController = TextEditingController(text: formatDateTime(widget.event.startTime));
    endTimeController = TextEditingController(text: formatDateTime(widget.event.endTime));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: startTimeController,
              decoration: InputDecoration(labelText: 'Start Time (YYYY-MM-DD HH:MM)'),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: endTimeController,
              decoration: InputDecoration(labelText: 'End Time (YYYY-MM-DD HH:MM)'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _saveChanges(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges(BuildContext context) {
    // Implement the logic to save changes and update the event
    // Use the provided controllers to get the edited values
    // Update the event data and navigate back to the EventScreen or CalendarPage

    // Example:
    setState(() {
      widget.event.subject = titleController.text;

      // Parse the entered date-time strings to DateTime objects
      widget.event.startTime = DateTime.parse(startTimeController.text);
      widget.event.endTime = DateTime.parse(endTimeController.text);

      // Perform additional validation or logic if needed

      // Navigate back to the EventScreen
      Navigator.pop(context);
    });
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}