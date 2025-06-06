// lib/features/plant/presentation/pages/add_plant_page.dart
import 'package:flutter/material.dart';

class AddPlantPage extends StatelessWidget {
  const AddPlantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Plant'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Add Plant Form Goes Here'),
      ),
    );
  }
}
