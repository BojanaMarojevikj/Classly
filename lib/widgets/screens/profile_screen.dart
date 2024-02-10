import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();

  List<User> users = [];

  Future<void> getUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      users = snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    });
  }

  Future<void> createUser({
    required String name,
    required int age,
    required String birthday,
  }) async {
    try {
      final docUser = FirebaseFirestore.instance.collection('users').doc();

      final user = User(
        id: docUser.id,
        name: name,
        age: age,
        birthday: birthday,
      );
      final json = user.toJson();

      await docUser.set(json);
      await getUsers(); // Refresh the user list
    } catch (e) {
      print('Firestore Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text('Age: ${user.age}, Birthday: ${user.birthday}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => _buildAddUserDialog(),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildAddUserDialog() {
    return AlertDialog(
      title: Text('Add User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: ageController,
            decoration: InputDecoration(
              labelText: 'Age',
            ),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: birthdayController,
            decoration: InputDecoration(
              labelText: 'Birthday (YYYY-MM-DD)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = nameController.text;
            final age = int.tryParse(ageController.text) ?? 0;
            final birthday = birthdayController.text;

            createUser(name: name, age: age, birthday: birthday);
            nameController.clear();
            ageController.clear();
            birthdayController.clear();
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class User {
  String id;
  final String name;
  final int age;
  final String birthday;

  User({
    this.id = '',
    required this.name,
    required this.age,
    required this.birthday,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      birthday: json['birthday'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'birthday': birthday,
    };
  }
}
