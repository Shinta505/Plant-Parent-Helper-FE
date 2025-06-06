// lib/features/plant/data/repositories/plant_repository_impl.dart
import 'package:fe/core/api/api_client.dart';
import 'package:fe/core/constants/api_constants.dart';
import 'package:fe/features/plant/data/models/plant_model.dart';
import 'package:fe/features/plant/domain/entities/plant.dart';
import 'package:fe/features/plant/domain/repositories/plant_repository.dart';

class PlantRepositoryImpl implements PlantRepository {
  final ApiClient apiClient;

  PlantRepositoryImpl({required this.apiClient});

  @override
  Future<List<Plant>> getMyPlants() async {
    final response = await apiClient.get(ApiConstants.plants);
    final data = response.data as List;
    return data.map((plant) => PlantModel.fromJson(plant)).toList();
  }

  @override
  Future<void> addPlant(Plant plant) async {
    final plantModel = PlantModel(
      id: plant.id,
      name: plant.name,
      type: plant.type,
      room: plant.room,
      wateringSchedule: plant.wateringSchedule,
      fertilizingSchedule: plant.fertilizingSchedule,
    );
    await apiClient.post(ApiConstants.addPlant, data: plantModel.toJson());
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    final plantModel = PlantModel(
      id: plant.id,
      name: plant.name,
      type: plant.type,
      room: plant.room,
      wateringSchedule: plant.wateringSchedule,
      fertilizingSchedule: plant.fertilizingSchedule,
    );
    await apiClient.post('${ApiConstants.updatePlant}/${plant.id}',
        data: plantModel.toJson());
  }

  @override
  Future<void> deletePlant(String plantId) async {
    await apiClient.post('${ApiConstants.deletePlant}/$plantId');
  }
}
