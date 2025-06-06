// lib/features/plant/presentation/bloc/plant_state.dart
import 'package:equatable/equatable.dart';
import 'package:fe/features/plant/domain/entities/plant.dart';

abstract class PlantState extends Equatable {
  const PlantState();

  @override
  List<Object> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<Plant> plants;

  const PlantLoaded(this.plants);

  @override
  List<Object> get props => [plants];
}

class PlantError extends PlantState {
  final String message;

  const PlantError(this.message);

  @override
  List<Object> get props => [message];
}
