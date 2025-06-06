// lib/features/plant/domain/repositories/plant_repository.dart
import 'package:fe/features/plant/domain/entities/plant.dart';

abstract class PlantRepository {
  Future<List<Plant>> getMyPlants();
  Future<void> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String plantId);
}
