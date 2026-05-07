import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/assignment_model.dart';

class AssignmentService {
  static final AssignmentService _instance = AssignmentService._internal();
  factory AssignmentService() => _instance;
  AssignmentService._internal();

  List<Assignment>? _cachedAssignments;

  /// Load all assignments from JSON
  Future<List<Assignment>> getAllAssignments() async {
    if (_cachedAssignments != null) return _cachedAssignments!;

    try {
      final String response = await rootBundle.loadString(
        'lib/data/assignments.json',
      );
      final List<dynamic> data = json.decode(response);

      _cachedAssignments = data
          .map((json) => Assignment.fromJson(json))
          .toList();

      return _cachedAssignments!;
    } catch (e) {
      throw Exception("Failed to load assignments: $e");
    }
  }

  /// Get only pending assignments
  Future<List<Assignment>> getPendingAssignments() async {
    final all = await getAllAssignments();
    return all.where((a) => a.isPending).toList();
  }

  /// Get only submitted assignments
  Future<List<Assignment>> getSubmittedAssignments() async {
    final all = await getAllAssignments();
    return all.where((a) => a.isSubmitted).toList();
  }

  /// Get overdue assignments (pending + due date passed)
  Future<List<Assignment>> getOverdueAssignments() async {
    final pending = await getPendingAssignments();
    return pending.where((a) => a.isOverdue).toList();
  }

  /// Get assignments by subject
  Future<List<Assignment>> getAssignmentsBySubject(String subject) async {
    final all = await getAllAssignments();
    return all.where((a) => a.subject == subject).toList();
  }

  /// Clear cache (useful for refresh)
  void clearCache() {
    _cachedAssignments = null;
  }
}
