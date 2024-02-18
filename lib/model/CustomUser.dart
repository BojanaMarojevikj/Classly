import 'package:firebase_auth/firebase_auth.dart';

import 'Course.dart';

class CustomUser {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String photoURL;
  List<Course> enrolledCourses;

  CustomUser({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.photoURL,
    List<Course>? enrolledCourses,
  }) : enrolledCourses = enrolledCourses ?? [];

  factory CustomUser.fromFirebaseUser(User user) {
    return CustomUser(
      uid: user.uid,
      email: user.email ?? '',
      firstName: user.displayName?.split(' ')[0] ?? '',
      lastName: user.displayName?.split(' ')[1] ?? '',
      photoURL: user.photoURL ?? '',
    );
  }

  getFullName() {
    return '$firstName $lastName';
  }

  void enrollInCourse(Course course) {
    enrolledCourses.add(course);
  }

  bool isEnrolledInCourse(Course course) {
    return enrolledCourses.contains(course);
  }
}