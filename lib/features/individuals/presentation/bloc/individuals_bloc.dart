import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'individuals_event.dart';
part 'individuals_state.dart';

class IndividualsBloc extends Bloc<IndividualsEvent, IndividualsState> {
  IndividualsBloc() : super(IndividualsInitial()) {
    on<IndividualsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
