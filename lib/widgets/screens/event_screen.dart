import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventScreen extends StatefulWidget {
  final Appointment event;
  final Function(Appointment) onDelete;
  final Function(Appointment, String, String, String, String) onEdit;

  EventScreen({required this.event, required this.onDelete, required this.onEdit});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              _editEvent(context);
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
                Navigator.pop(context); // Close the confirmation dialog
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

  void _editEvent(BuildContext context) {
    TextEditingController titleController = TextEditingController(text: widget.event.subject);
    TextEditingController dateController = TextEditingController(text: formatDate(widget.event.startTime));
    TextEditingController timeController = TextEditingController(text: formatTime(widget.event.startTime));
    TextEditingController durationController = TextEditingController(text: widget.event.endTime.difference(widget.event.startTime).inHours.toString());

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
                Navigator.pop(context); // Close the edit dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onEdit(
                  widget.event,
                  titleController.text,
                  dateController.text,
                  timeController.text,
                  durationController.text,
                );
                Navigator.pop(context); // Close the edit dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}