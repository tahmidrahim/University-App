class StudentRoutine {
  final String program;
  final String department;
  final String year;
  final String semester;
  final String section;
  final Map<String, List<Course>> weeklySchedule;

  StudentRoutine({
    required this.program,
    required this.department,
    required this.year,
    required this.semester,
    required this.section,
    required this.weeklySchedule,
  });

  factory StudentRoutine.fromJson(Map<String, dynamic> json) {
    var scheduleMap = json['weekly_schedule'] as Map<String, dynamic>;
    Map<String, List<Course>> parsedSchedule = {};

    scheduleMap.forEach((day, courses) {
      parsedSchedule[day] = (courses as List)
          .map((courseJson) => Course.fromJson(courseJson))
          .toList();
    });

    return StudentRoutine(
      program: json['program'],
      department: json['department'],
      year: json['year'],
      semester: json['semester'],
      section: json['section'],
      weeklySchedule: parsedSchedule,
    );
  }
}

class Course {
  final String time;
  final String courseCode;
  final String teacher;
  final String? room;

  Course({
    required this.time,
    required this.courseCode,
    required this.teacher,
    this.room,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      time: json['time'],
      courseCode: json['course_code'],
      teacher: json['teacher'],
      room: json['room'], // This can be null, which is fine
    );
  }
}
