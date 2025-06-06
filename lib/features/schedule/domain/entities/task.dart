// lib/features/schedule/domain/entities/task.dart
import 'package:equatable/equatable.dart';
import 'package:fe/features/plant/domain/entities/plant.dart';

enum TaskType { watering, fertilizing }

class Task extends Equatable {
  final String id;
  final Plant plant;
  final TaskType taskType;
  final DateTime dueDate;

  const Task({
    required this.id,
    required this.plant,
    required this.taskType,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [id, plant, taskType, dueDate];
}
