// lib/features/plant/presentation/pages/my_plants_page.dart
import 'package:fe/features/plant/presentation/bloc/plant_bloc.dart';
import 'package:fe/features/plant/presentation/bloc/plant_event.dart';
import 'package:fe/features/plant/presentation/bloc/plant_state.dart';
import 'package:fe/features/plant/presentation/widgets/plant_card.dart';
import 'package:fe/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPlantsPage extends StatefulWidget {
  const MyPlantsPage({super.key});

  @override
  State<MyPlantsPage> createState() => _MyPlantsPageState();
}

class _MyPlantsPageState extends State<MyPlantsPage> {
  @override
  void initState() {
    super.initState();
    // Load plants when the page is initialized
    context.read<PlantBloc>().add(LoadPlants());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Plants', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<PlantBloc, PlantState>(
        builder: (context, state) {
          if (state is PlantLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PlantLoaded) {
            if (state.plants.isEmpty) {
              return Center(
                child: Text(
                  'No plants yet. Add one!',
                  style: GoogleFonts.poppins(),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.plants.length,
              itemBuilder: (context, index) {
                final plant = state.plants[index];
                return PlantCard(plant: plant);
              },
            );
          }
          if (state is PlantError) {
            return Center(child: Text(state.message));
          }
          return Center(
              child: Text(
            'Welcome! Add your first plant.',
            style: GoogleFonts.poppins(),
          ));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.addPlantRoute);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
