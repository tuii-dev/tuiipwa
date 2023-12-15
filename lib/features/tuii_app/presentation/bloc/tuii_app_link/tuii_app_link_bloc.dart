import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/expire_app_link_command.dart';
import 'package:tuiiapp_domain_data_firestore/file/domain/usecases/get_app_link_command.dart';
import 'package:tuiientitymodels/files/tuii_app/data/models/app_link_command_model.dart';

part 'tuii_app_link_event.dart';
part 'tuii_app_link_state.dart';

class TuiiAppLinkBloc extends Bloc<TuiiAppLinkEvent, TuiiAppLinkState> {
  TuiiAppLinkBloc({
    required this.getAppLinkCommand,
    required this.expireAppLinkCommand,
  }) : super(TuiiAppLinkState.initial()) {
    on<AddAppLinkCommandEvent>(_mapAddAppLinkCommandEventToState);

    on<ClearAppLinkCommandEvent>(_mapClearAppLinkCommandEventToState);

    on<UpdateAppLinkCommandEvent>((event, emit) => emit(state.copyWith(
        status: event.status, appLinkCommand: event.appLinkCommand)));
  }

  final GetAppLinkCommandUseCase getAppLinkCommand;
  final ExpireAppLinkCommandUseCase expireAppLinkCommand;
  // final GetSystemConfigurationUseCase getSystemConfiguration;

  init(String? key) {
    if (key != null && key.trim().isNotEmpty) {
      add(AddAppLinkCommandEvent(key: key));
    }
  }

  _mapAddAppLinkCommandEventToState(
      AddAppLinkCommandEvent event, Emitter<TuiiAppLinkState> emit) async {
    if (event.key.isNotEmpty) {
      final appLinkEither =
          await getAppLinkCommand(GetAppLinkCommandParams(key: event.key));

      appLinkEither.fold((error) {
        // Will never happen
        debugPrint('An error ocurred!');
        emit(state.copyWith(
            status: TuiiAppLinkStatus.error,
            message: 'AppLinkCommand processing failed'));
      }, (cmd) {
        debugPrint('AppLinkCommand successfully loaded');
        emit(state.copyWith(
            status: TuiiAppLinkStatus.pendingCommand, appLinkCommand: cmd));
      });
    } else {
      emit(state.copyWith(
          status: TuiiAppLinkStatus.error,
          message: 'AppLinkCommand key not specified'));
    }
  }

  _mapClearAppLinkCommandEventToState(
      ClearAppLinkCommandEvent event, Emitter<TuiiAppLinkState> emit) async {
    if (event.key.isNotEmpty) {
      final expireEither = await expireAppLinkCommand(
          ExpireAppLinkCommandParams(key: event.key));

      expireEither.fold((error) {
        // Will never happen
        debugPrint('An error ocurred!');
        emit(state.copyWith(
            status: TuiiAppLinkStatus.error,
            message: 'Expire AppLinkCommand processing failed'));
      }, (success) {
        debugPrint('Expire AppLinkCommand successfully loaded');
        emit(TuiiAppLinkState.empty());
      });
    } else {
      emit(state.copyWith(
          status: TuiiAppLinkStatus.error,
          message: 'AppLinkCommand key not specified'));
    }
  }
}
