class Course {
  final String courseId;
  final String courseName;

  Course({
    required this.courseId,
    required this.courseName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Course &&
              runtimeType == other.runtimeType &&
              courseId == other.courseId &&
              courseName == other.courseName;

  @override
  int get hashCode => courseId.hashCode ^ courseName.hashCode;
}