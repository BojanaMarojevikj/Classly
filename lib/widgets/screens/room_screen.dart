import 'package:flutter/material.dart';
import '../../model/Room.dart';

class RoomInfoScreen extends StatelessWidget {
  final Room room;

  RoomInfoScreen({required this.room});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${room.name}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Text('Building: ${room.building}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10.0),
            Text('Floor: ${room.floor}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20.0),
            Text(
              'Seats:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            buildSeatGrid(room.seats),
          ],
        ),
      ),
    );
  }

  Widget buildSeatGrid(List<int> seats) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: seats.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: seats[index] == 0 ? Colors.grey : Colors.green,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              seats[index].toString(),
              style: TextStyle(
                color: seats[index] == 0 ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
