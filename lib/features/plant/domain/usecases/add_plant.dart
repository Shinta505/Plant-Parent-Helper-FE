// lib/features/plant/domain/usecases/add_plant.dart
import 'package:fe/features/plant/domain/entities/plant.dart';
import 'package:fe/features/plant/domain/repositories/plant_repository.dart';

class AddPlant {
  final PlantRepository repository;

  AddPlant(this.repository);

  Future<void> call(Plant plant) {
    return repository.addPlant(plant);
  }
}
