// lib/features/schedule/presentation/bloc/schedule_state.dart
import 'package:equatable/equatable.dart';
import 'package:fe/features/schedule/domain/entities/task.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<Task> tasks;

  const ScheduleLoaded(this.tasks);

  @override
  List<Object> get props => [tasks];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object> get props => [message];
}
