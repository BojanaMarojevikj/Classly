class Course {
  final String courseId;
  final String courseName;

  Course({
    required this.courseId,
    required this.courseName,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Course &&
              runtimeType == other.runtimeType &&
              courseId == other.courseId &&
              courseName == other.courseName;

  @override
  int get hashCode => courseId.hashCode ^ courseName.hashCode;

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
    };
  }
}
