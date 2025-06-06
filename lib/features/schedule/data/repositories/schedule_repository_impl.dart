// lib/features/schedule/data/repositories/schedule_repository_impl.dart
import 'package:fe/features/plant/domain/repositories/plant_repository.dart';
import 'package:fe/features/schedule/domain/entities/task.dart';
import 'package:fe/features/schedule/domain/repositories/schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final PlantRepository plantRepository;

  ScheduleRepositoryImpl({required this.plantRepository});

  @override
  Future<List<Task>> getTodaySchedule() async {
    final plants = await plantRepository.getMyPlants();
    final today = DateTime.now();
    final List<Task> tasks = [];

    for (var plant in plants) {
      if (isSameDay(plant.wateringSchedule, today)) {
        tasks.add(Task(
            id: '${plant.id}_water',
            plant: plant,
            taskType: TaskType.watering,
            dueDate: plant.wateringSchedule));
      }
      if (isSameDay(plant.fertilizingSchedule, today)) {
        tasks.add(Task(
            id: '${plant.id}_fertilize',
            plant: plant,
            taskType: TaskType.fertilizing,
            dueDate: plant.fertilizingSchedule));
      }
    }
    return tasks;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
