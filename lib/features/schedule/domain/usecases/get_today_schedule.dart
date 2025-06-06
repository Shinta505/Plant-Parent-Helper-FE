// lib/features/schedule/domain/usecases/get_today_schedule.dart
import 'package:fe/features/schedule/domain/entities/task.dart';
import 'package:fe/features/schedule/domain/repositories/schedule_repository.dart';

class GetTodaySchedule {
  final ScheduleRepository repository;

  GetTodaySchedule(this.repository);

  Future<List<Task>> call() {
    return repository.getTodaySchedule();
  }
}
