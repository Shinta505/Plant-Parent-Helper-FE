// lib/features/plant/presentation/bloc/plant_event.dart
import 'package:equatable/equatable.dart';
import 'package:fe/features/plant/domain/entities/plant.dart';

abstract class PlantEvent extends Equatable {
  const PlantEvent();

  @override
  List<Object> get props => [];
}

class LoadPlants extends PlantEvent {}

class AddNewPlant extends PlantEvent {
  final Plant plant;

  const AddNewPlant(this.plant);

  @override
  List<Object> get props => [plant];
}
