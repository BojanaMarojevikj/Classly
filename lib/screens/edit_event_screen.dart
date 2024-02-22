import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
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
    setState(() {
      widget.event.subject = titleController.text;
      widget.event.startTime = DateTime.parse(startTimeController.text);
      widget.event.endTime = DateTime.parse(endTimeController.text);
      Navigator.pop(context);
    });
  }

  String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}