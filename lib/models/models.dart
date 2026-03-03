import 'package:flutter/material.dart';

class Teacher {
  final String id;
  final String name;
  final String role;
  final String initials;
  final Color avatarColor;
  bool isOnline;
  final String department;
  final String password;
  final String? backgroundPath;

  Teacher({
    required this.id,
    required this.name,
    required this.role,
    required this.initials,
    required this.avatarColor,
    this.department = 'General',
    this.isOnline = false,
    this.password = '1234',
    this.backgroundPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'initials': initials,
    'avatarColor': avatarColor.value,
    'department': department,
    'isOnline': isOnline,
    'password': password,
    'backgroundPath': backgroundPath,
  };

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    id: json['id'],
    name: json['name'],
    role: json['role'],
    initials: json['initials'],
    avatarColor: Color(json['avatarColor']),
    department: json['department'] ?? 'General',
    isOnline: json['isOnline'],
    password: json['password'],
    backgroundPath: json['backgroundPath'],
  );
}

enum AbsenceStatus { pending, approved, rejected }

enum AbsenceType { sick, personal, annual, training }

class Absence {
  final String id;
  final String teacherId;
  final String teacherName;
  final DateTime startDate;
  final DateTime endDate;
  final AbsenceType type;
  AbsenceStatus status;

  Absence({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.status = AbsenceStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'type': type.index,
    'status': status.index,
  };

  factory Absence.fromJson(Map<String, dynamic> json) => Absence(
    id: json['id'],
    teacherId: json['teacherId'],
    teacherName: json['teacherName'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    type: AbsenceType.values[json['type']],
    status: AbsenceStatus.values[json['status']],
  );
}

class Shift {
  final String id;
  final String teacherId;
  final String teacherName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String subject;
  final Color color;

  Shift({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'subject': subject,
    'color': color.value,
  };

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
    id: json['id'],
    teacherId: json['teacherId'],
    teacherName: json['teacherName'],
    date: DateTime.parse(json['date']),
    startTime: json['startTime'],
    endTime: json['endTime'],
    subject: json['subject'],
    color: Color(json['color']),
  );
}

class Student {
  final String id;
  final String name;
  final String grade;
  final String parentEmail;
  final Color avatarColor;
  final DateTime dateOfBirth;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.parentEmail,
    required this.avatarColor,
    required this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade': grade,
    'parentEmail': parentEmail,
    'avatarColor': avatarColor.value,
    'dateOfBirth': dateOfBirth.toIso8601String(),
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'],
    name: json['name'],
    grade: json['grade'],
    parentEmail: json['parentEmail'],
    avatarColor: Color(json['avatarColor']),
    dateOfBirth: json['dateOfBirth'] != null
        ? DateTime.parse(json['dateOfBirth'])
        : DateTime.now(), // Fallback for existing data
  );
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String? titleKey;
  final String? messageKey;
  final Map<String, String>? args;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.titleKey,
    this.messageKey,
    this.args,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'titleKey': titleKey,
    'messageKey': messageKey,
    'args': args,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      titleKey: json['titleKey'],
      messageKey: json['messageKey'],
      args: json['args'] != null
          ? Map<String, String>.from(json['args'])
          : null,
    );
  }
}
