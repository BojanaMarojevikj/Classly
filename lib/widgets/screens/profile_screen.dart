import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/CustomUser.dart';
import '../../model/Course.dart';
import '../../screens/login_screen.dart';
import '../../service/AuthService.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _firebaseService = AuthService();

  late CustomUser? _user;
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  List<Course> _selectedCourses = [];

  @override
  void initState() {
    super.initState();
    _updateUser();
    _fetchEnrolledCourses();
    _fetchAvailableCourses();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _updateUser();
    });
  }

  void _updateUser() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _user = CustomUser.fromFirebaseUser(currentUser);
    }
  }

  void _fetchEnrolledCourses() {
    if (_user != null) {
      FirebaseFirestore.instance.collection('custom_users')
          .doc(_user!.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          List<
              dynamic>? enrolledCoursesData = documentSnapshot['enrolledCourses'];

          if (enrolledCoursesData != null) {
            List<Course> enrolledCourses = [];

            for (var courseData in enrolledCoursesData) {
              Course course = Course(
                courseId: courseData['courseId'] ?? '',
                courseName: courseData['courseName'] ?? '',
              );
              enrolledCourses.add(course);
            }

            setState(() {
              _enrolledCourses = enrolledCourses;
            });
            print('Enrolled courses: $_enrolledCourses');
          }
        }
      }).catchError((error) {
        print('Error fetching enrolled courses: $error');
      });
    }
  }

  void _fetchAvailableCourses() {
    FirebaseFirestore.instance.collection('courses').get().then((
        QuerySnapshot querySnapshot) {
      List<Course> courses = [];
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        Course course = Course(
          courseId: document.id,
          courseName: document['courseName'] ?? '',
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

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(_firebaseService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'User Name:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _user?.getFullName() ?? 'No name available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            const Text(
              'User Email:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _user?.email ?? 'No email available',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Enrolled Courses:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            for (Course course in _enrolledCourses)
              Text(
                course.courseName,
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEnrollmentDialog(context);
        },
        tooltip: 'Enroll in Course',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showEnrollmentDialog(BuildContext context) async {
    List<Course> availableCoursesCopy = List.from(_availableCourses);
    _fetchEnrolledCourses();
    for (Course enrolledCourse in _enrolledCourses) {
      int index = availableCoursesCopy.indexWhere(
              (course) => course.courseId == enrolledCourse.courseId);
      print('Index: $index');
      if (index != -1) {
        availableCoursesCopy[index] = enrolledCourse;
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Available Courses'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: availableCoursesCopy.map((Course course) {
                    return CheckboxListTile(
                      title: Text(course.courseName),
                      value: _selectedCourses.contains(course),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value != null && value) {
                            _selectedCourses.add(course);
                          } else {
                            _selectedCourses.remove(course);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Enroll'),
              onPressed: () {
                Navigator.of(context).pop();
                _enrollInCourses();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _enrollInCourses() {
    if (_selectedCourses.isNotEmpty) {
      if (_user != null) {
        List<Map<String, String>> coursesData = _selectedCourses
            .map((course) =>
        {
          'courseId': course.courseId,
          'courseName': course.courseName,
        })
            .toList();

        FirebaseFirestore.instance.collection('custom_users')
            .doc(_user!.uid)
            .update({
          'enrolledCourses': FieldValue.arrayUnion(coursesData),
        })
            .then((value) {
          print('Courses enrolled successfully!');
          _fetchEnrolledCourses();
        }).catchError((error) {
          print('Error enrolling in courses: $error');
        });
      }

      setState(() {
        _selectedCourses = [];
      });
    }
  }
}
