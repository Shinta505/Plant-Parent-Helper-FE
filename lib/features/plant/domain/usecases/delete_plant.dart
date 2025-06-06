// lib/features/plant/domain/usecases/delete_plant.dart
import 'package:fe/features/plant/domain/repositories/plant_repository.dart';

class DeletePlant {
  final PlantRepository repository;

  DeletePlant(this.repository);

  Future<void> call(String plantId) {
    return repository.deletePlant(plantId);
  }
}
