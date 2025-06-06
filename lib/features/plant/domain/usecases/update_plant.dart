// lib/features/plant/domain/usecases/update_plant.dart
import 'package:fe/features/plant/domain/entities/plant.dart';
import 'package:fe/features/plant/domain/repositories/plant_repository.dart';

class UpdatePlant {
  final PlantRepository repository;

  UpdatePlant(this.repository);

  Future<void> call(Plant plant) {
    return repository.updatePlant(plant);
  }
}
