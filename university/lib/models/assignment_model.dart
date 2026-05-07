import 'package:flutter/foundation.dart';

@immutable
class Assignment {
  final String title;
  final String subject;
  final String dueDate;
  final String status;
  final String? priority; // Optional, since not in your JSON

  const Assignment({
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    this.priority,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      title: json['title'] as String,
      subject: json['subject'] as String,
      dueDate: json['dueDate'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
      'status': status,
      if (priority != null) 'priority': priority,
    };
  }

  // Helper getters
  bool get isPending => status == 'pending';
  bool get isSubmitted => status == 'submitted';
  bool get isGraded => status == 'graded';

  // Check if overdue (only for pending assignments)
  bool get isOverdue {
    if (!isPending) return false;
    final due = DateTime.tryParse(dueDate);
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  @override
  String toString() => 'Assignment(title: $title, status: $status)';
}
