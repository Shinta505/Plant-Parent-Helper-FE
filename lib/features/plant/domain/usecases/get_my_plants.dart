// lib/features/plant/domain/usecases/get_my_plants.dart
import 'package:fe/features/plant/domain/entities/plant.dart';
import 'package:fe/features/plant/domain/repositories/plant_repository.dart';

class GetMyPlants {
  final PlantRepository repository;

  GetMyPlants(this.repository);

  Future<List<Plant>> call() {
    return repository.getMyPlants();
  }
}
