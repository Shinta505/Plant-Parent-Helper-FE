// lib/features/plant/data/models/plant_model.dart
import 'package:fe/features/plant/domain/entities/plant.dart';

class PlantModel extends Plant {
  const PlantModel({
    required super.id,
    required super.name,
    required super.type,
    required super.room,
    required super.wateringSchedule,
    required super.fertilizingSchedule,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      room: json['room'],
      wateringSchedule: DateTime.parse(json['wateringSchedule']),
      fertilizingSchedule: DateTime.parse(json['fertilizingSchedule']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'room': room,
      'wateringSchedule': wateringSchedule.toIso8601String(),
      'fertilizingSchedule': fertilizingSchedule.toIso8601String(),
    };
  }
}
