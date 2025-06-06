// lib/features/plant/domain/entities/plant.dart
import 'package:equatable/equatable.dart';

class Plant extends Equatable {
  final String id;
  final String name;
  final String type;
  final String room;
  final DateTime wateringSchedule;
  final DateTime fertilizingSchedule;

  const Plant({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    required this.wateringSchedule,
    required this.fertilizingSchedule,
  });

  @override
  List<Object?> get props =>
      [id, name, type, room, wateringSchedule, fertilizingSchedule];
}
