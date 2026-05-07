import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/routine_model.dart';

class RoutineService {
  // Singleton pattern so we don't reload the file multiple times
  static final RoutineService _instance = RoutineService._internal();
  factory RoutineService() => _instance;
  RoutineService._internal();

  StudentRoutine? _cachedRoutine;

  Future<StudentRoutine> getRoutine() async {
    if (_cachedRoutine != null) return _cachedRoutine!;

    try {
      final String response = await rootBundle.loadString(
        'lib/data/routine.json',
      );
      final data = json.decode(response);
      _cachedRoutine = StudentRoutine.fromJson(data);
      return _cachedRoutine!;
    } catch (e) {
      throw Exception("Failed to load routine: $e");
    }
  }

  Future<List<Course>> getClassesForDay(String dayName) async {
    final routine = await getRoutine();
    return routine.weeklySchedule[dayName] ?? [];
  }
}
