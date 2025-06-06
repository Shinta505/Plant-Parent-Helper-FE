// lib/features/schedule/presentation/bloc/schedule_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fe/features/schedule/domain/usecases/get_today_schedule.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetTodaySchedule getTodaySchedule;

  ScheduleBloc({required this.getTodaySchedule}) : super(ScheduleInitial()) {
    on<LoadTodaySchedule>((event, emit) async {
      emit(ScheduleLoading());
      try {
        final tasks = await getTodaySchedule();
        emit(ScheduleLoaded(tasks));
      } catch (e) {
        emit(ScheduleError(e.toString()));
      }
    });
  }
}
