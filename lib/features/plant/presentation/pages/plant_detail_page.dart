// lib/features/plant/presentation/pages/plant_detail_page.dart
import 'package:flutter/material.dart';

class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Details'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Details of a specific plant.'),
      ),
    );
  }
}
