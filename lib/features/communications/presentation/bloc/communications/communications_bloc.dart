import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'communications_event.dart';
part 'communications_state.dart';

class CommunicationsBloc extends Bloc<CommunicationsEvent, CommunicationsState> {
  CommunicationsBloc() : super(CommunicationsInitial()) {
    on<CommunicationsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
