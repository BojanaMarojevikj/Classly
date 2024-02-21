import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../model/CustomUser.dart';
import '../../model/Course.dart';
import '../../screens/login_screen.dart';
import '../../service/AuthService.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _firebaseService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();

  late CustomUser? _user;
  List<Course> _enrolledCourses = [];
  List<Course> _availableCourses = [];
  List<Course> _selectedCourses = [];
  Uint8List? _profileImage;

  @override
  void initState() {
    super.initState();
    _updateUser();
    _fetchEnrolledCourses();
    _fetchAvailableCourses();
    _auth.authStateChanges().listen((User? user) {
      _updateUser();
    });
  }


  void _updateUser() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      _user = CustomUser.fromFirebaseUser(currentUser);

      try {
        DocumentSnapshot documentSnapshot =
        await _firestore.collection('custom_users').doc(_user!.uid).get();

        if (documentSnapshot.exists) {
          String? profileImageUrl = documentSnapshot['profileImageUrl'];

          if (profileImageUrl != null) {
            http.Response response = await http.get(Uri.parse(profileImageUrl));
            setState(() {
              _profileImage = Uint8List.fromList(response.bodyBytes);
            });
          }
        }
      } catch (error) {
        print('Error loading profile image: $error');
      }
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
            GestureDetector(
              onTap: _showImageSourceOptions, // Call the method when the user taps on the image
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? MemoryImage(_profileImage!)
                    : NetworkImage('https://icons.iconarchive.com/icons/papirus-team/papirus-status/512/avatar-default-icon.png') as ImageProvider,
              ),
            ),
            SizedBox(height: 16),
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

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (pickedFile == null) {
        return;
      }

      await _uploadProfileImageAndSetUser(File(pickedFile.path));
    } catch (error) {
      print('Error picking image from camera: $error');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return; // User canceled image picking
      }

      await _uploadProfileImageAndSetUser(File(pickedFile.path));
    } catch (error) {
      print('Error picking image from gallery: $error');
    }
  }

  Future<void> _uploadProfileImageAndSetUser(File imageFile) async {
    try {
      if (_user != null) {
        // Upload image to storage
        String imageUrl = await _uploadProfileImageToStorage(imageFile);

        // Update user profile in Firestore
        await _updateUserProfileImage(imageUrl);

        // Update the local user object
        setState(() {
          _user!.photoURL = imageUrl;
        });

        // Update the profile image
        setState(() {
          _profileImage = MemoryImage(imageFile.readAsBytesSync()) as Uint8List?;
        });

        print('Profile image uploaded and user profile updated');
      } else {
        print('User object is null.');
      }
    } catch (error) {
      print('Error uploading profile image: $error');
    }
  }

  Future<String> _uploadProfileImageToStorage(File imageFile) async {
    try {
      String fileName = 'profile_images/${_user!.uid}.png';
      print('Storage Path: $fileName');

      Reference storageReference =
      FirebaseStorage.instance.ref().child(fileName);

      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => print('Profile image uploaded'));

      return await storageReference.getDownloadURL();
    } catch (error) {
      print('Error uploading profile image to storage: $error');
      throw error; // Rethrow the error to handle it in the calling function
    }
  }

  Future<void> _updateUserProfileImage(String imageUrl) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentReference userReference =
        FirebaseFirestore.instance.collection('custom_users').doc(currentUser.uid);

        // Update the user document with the profile image URL
        await userReference.update({
          'profileImageUrl': imageUrl,
        });

        print('User profile image URL updated successfully.');
      }
    } catch (error) {
      print('Error updating user profile image: $error');
      throw error; // Rethrow the error to handle it in the calling function
    }
  }




  Future<void> _showEnrollmentDialog(BuildContext context) async {
    List<Course> availableCoursesCopy = List.from(_availableCourses);
    _fetchEnrolledCourses();
    for (Course enrolledCourse in _enrolledCourses) {
      int index = availableCoursesCopy.indexWhere(
            (course) => course.courseId == enrolledCourse.courseId,
      );
      print('Index: $index');
      if (index != -1) {
        _selectedCourses.add(enrolledCourse);
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
    if (_user != null) {
      List<Map<String, String>> coursesToEnroll = _selectedCourses
          .map((course) => {
        'courseId': course.courseId,
        'courseName': course.courseName,
      })
          .toList();

      List<Map<String, String>> coursesToDisenroll = _enrolledCourses
          .where((course) => !_selectedCourses.contains(course))
          .map((course) => {
        'courseId': course.courseId,
        'courseName': course.courseName,
      })
          .toList();

      FirebaseFirestore.instance.collection('custom_users').doc(_user!.uid).update({
        'enrolledCourses': FieldValue.arrayUnion(coursesToEnroll),
      }).then((value) {
        print('Courses enrolled successfully!');
        _fetchEnrolledCourses();
      }).catchError((error) {
        print('Error enrolling in courses: $error');
      });

      FirebaseFirestore.instance.collection('custom_users').doc(_user!.uid).update({
        'enrolledCourses': FieldValue.arrayRemove(coursesToDisenroll),
      }).then((value) {
        print('Courses disenrolled successfully!');
        _fetchEnrolledCourses();
      }).catchError((error) {
        print('Error disenrolling from courses: $error');
      });
    }

    setState(() {
      _selectedCourses = [];
    });
  }
}

