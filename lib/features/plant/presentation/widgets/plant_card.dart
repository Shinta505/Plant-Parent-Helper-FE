// lib/features/plant/presentation/widgets/plant_card.dart
import 'package:flutter/material.dart';
import 'package:fe/features/plant/domain/entities/plant.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.local_florist, color: Colors.green.shade800),
        ),
        title: Text(
          plant.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${plant.type} in ${plant.room}',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 5),
            Text(
              'Next Watering: ${DateFormat.yMMMd().format(plant.wateringSchedule)}',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          // Navigate to plant detail page
        },
      ),
    );
  }
}
