import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'tuii_app_event.dart';
part 'tuii_app_state.dart';

class TuiiAppBloc extends Bloc<TuiiAppEvent, TuiiAppState> {
  TuiiAppBloc() : super(TuiiAppInitial()) {
    on<TuiiAppEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
