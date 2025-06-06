// lib/features/schedule/domain/repositories/schedule_repository.dart
import 'package:fe/features/schedule/domain/entities/task.dart';

abstract class ScheduleRepository {
  Future<List<Task>> getTodaySchedule();
}
