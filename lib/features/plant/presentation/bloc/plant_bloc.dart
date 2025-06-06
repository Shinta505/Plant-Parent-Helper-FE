// lib/features/plant/presentation/bloc/plant_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fe/features/plant/domain/usecases/get_my_plants.dart';
import 'package:fe/features/plant/domain/usecases/add_plant.dart';
import 'plant_event.dart';
import 'plant_state.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final GetMyPlants getMyPlants;
  final AddPlant addPlant;

  PlantBloc({required this.getMyPlants, required this.addPlant})
      : super(PlantInitial()) {
    on<LoadPlants>((event, emit) async {
      emit(PlantLoading());
      try {
        final plants = await getMyPlants();
        emit(PlantLoaded(plants));
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });

    on<AddNewPlant>((event, emit) async {
      try {
        await addPlant(event.plant);
        add(LoadPlants()); // Reload plants after adding
      } catch (e) {
        emit(PlantError(e.toString()));
      }
    });
  }
}
