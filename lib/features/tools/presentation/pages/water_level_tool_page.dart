// lib/features/tools/presentation/pages/water_level_tool_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class WaterLevelToolPage extends StatefulWidget {
  const WaterLevelToolPage({super.key});

  @override
  State<WaterLevelToolPage> createState() => _WaterLevelToolPageState();
}

class _WaterLevelToolPageState extends State<WaterLevelToolPage> {
  double _x = 0.0, _y = 0.0;
  late StreamSubscription<AccelerometerEvent> _streamSubscription;

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        // ignore: deprecated_member_use
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        // We use a fraction of the accelerometer data to represent tilt
        _x = event.x / 10;
        _y = event.y / 10;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Level Tool', style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Place your phone on the pot',
              style: GoogleFonts.poppins(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Stack(
                children: [
                  // Animated bubble
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    top: 90 - _y * 80, // 90 is center, move based on y tilt
                    left: 90 + _x * 80, // 90 is center, move based on x tilt
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                  ),
                  // Center target
                  const Center(
                    child: Icon(Icons.add, color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Level the pot until the bubble is in the center',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ),
    );
  }
}
