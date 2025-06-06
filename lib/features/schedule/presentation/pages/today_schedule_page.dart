// lib/features/schedule/presentation/pages/today_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fe/features/schedule/presentation/bloc/schedule_bloc.dart';
import 'package:fe/features/schedule/presentation/bloc/schedule_event.dart';
import 'package:fe/features/schedule/presentation/bloc/schedule_state.dart';
import 'package:fe/features/schedule/domain/entities/task.dart';

class TodaySchedulePage extends StatefulWidget {
  const TodaySchedulePage({super.key});

  @override
  State<TodaySchedulePage> createState() => _TodaySchedulePageState();
}

class _TodaySchedulePageState extends State<TodaySchedulePage> {
  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(LoadTodaySchedule());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Schedule", style: GoogleFonts.poppins()),
        backgroundColor: Colors.green,
      ),
      body: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScheduleLoaded) {
            if (state.tasks.isEmpty) {
              return Center(
                child: Text(
                  'No tasks for today. Relax!',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Icon(
                      task.taskType == TaskType.watering
                          ? Icons.water_drop
                          : Icons.eco,
                      color: Colors.green,
                    ),
                    title: Text(
                      '${task.taskType.toString().split('.').last.capitalize()} ${task.plant.name}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'In ${task.plant.room}',
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              },
            );
          }
          if (state is ScheduleError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Loading schedule...'));
        },
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
