// lib/features/schedule/presentation/bloc/schedule_event.dart
import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class LoadTodaySchedule extends ScheduleEvent {}
