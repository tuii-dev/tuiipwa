// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tuiicore/core/enums/beacon_article_type.dart';
import 'package:tuiicore/core/enums/beacon_command_type.dart';
import 'package:tuiicore/core/models/beacon_command.dart';
import 'package:tuiipwa/web/constants/constants.dart';

part 'tuii_beacon_event.dart';
part 'tuii_beacon_state.dart';

class TuiiBeaconBloc extends Bloc<TuiiBeaconEvent, TuiiBeaconState> {
  html.BroadcastChannel? _channel;

  TuiiBeaconBloc() : super(TuiiBeaconState.initial()) {
    on<InitBeaconCommandChannelEvent>(_mapInitBeaconCommandChannelToState);

    on<ShowBeaconCommandEvent>(_mapShowBeaconCommandEventToState);

    on<HideBeaconCommandEvent>(_mapHideBeaconCommandEventToState);

    on<LoadArticleCommandEvent>(_mapLoadArticleCommandEventToState);

    on<OutgoingBeaconCommandEvent>(_mapOutgoingBeaconCommandEventToState);

    on<IncomingBeaconCommandEvent>(_mapIncomingBeaconCommandEventToState);
  }

  void init() {
    add(InitBeaconCommandChannelEvent());
  }

  _mapInitBeaconCommandChannelToState(InitBeaconCommandChannelEvent event,
      Emitter<TuiiBeaconState> emit) async {
    _channel = html.BroadcastChannel('flutter_beacon_bridge');
    _channel!.addEventListener('message', _beaconIncomingMessageHandler, true);
  }

  _mapShowBeaconCommandEventToState(
      ShowBeaconCommandEvent event, Emitter<TuiiBeaconState> emit) {
    _showBeacon(emit, event.openOnLoad ?? false);
  }

  _mapHideBeaconCommandEventToState(
      HideBeaconCommandEvent event, Emitter<TuiiBeaconState> emit) {
    if (_channel != null && state.beaconVisible == true) {
      final status = state.status == TuiiBeaconStatus.postMessageOn
          ? TuiiBeaconStatus.postMessageOff
          : TuiiBeaconStatus.postMessageOn;

      final command =
          const BeaconCommand(type: BeaconCommandType.destroy, payload: {})
              .toJson();
      _channel!.postMessage(command);

      emit(state.copyWith(status: status, beaconVisible: false));
    }
  }

  _mapLoadArticleCommandEventToState(
      LoadArticleCommandEvent event, Emitter<TuiiBeaconState> emit) {
    if (state.beaconVisible != true) {
      _showBeacon(emit, false);
      Future.delayed(const Duration(milliseconds: 500), () {
        var command = BeaconCommand(
            type: BeaconCommandType.article,
            payload: {'article': event.article.toMap()}).toJson();
        _channel!.postMessage(command);
      });
    } else {
      if (_channel != null) {
        String command = BeaconCommand(
            type: BeaconCommandType.article,
            payload: {'article': event.article.toMap()}).toJson();
        _channel!.postMessage(command);
      }
    }
  }

  _mapOutgoingBeaconCommandEventToState(
      OutgoingBeaconCommandEvent event, Emitter<TuiiBeaconState> emit) async {
    if (_channel != null) {
      String command = event.command.toJson();
      _channel!.postMessage(command);
    }
  }

  _mapIncomingBeaconCommandEventToState(
      IncomingBeaconCommandEvent event, Emitter<TuiiBeaconState> emit) async {
    final status = state.status == TuiiBeaconStatus.messageReceivedOn
        ? TuiiBeaconStatus.messageReceivedOff
        : TuiiBeaconStatus.messageReceivedOn;

    emit(state.copyWith(status: status, command: event.command));
  }

  void _beaconIncomingMessageHandler(event) {
    final e = event as html.MessageEvent;
    if (e.data != null && e.data['type'] != null) {
      final command = BeaconCommand.fromMap(e.data);
      add(IncomingBeaconCommandEvent(command: command));
    }
  }

  void _showBeacon(Emitter<TuiiBeaconState> emit, bool openOnLoad) {
    if (_channel != null) {
      final status = state.status == TuiiBeaconStatus.postMessageOn
          ? TuiiBeaconStatus.postMessageOff
          : TuiiBeaconStatus.postMessageOn;
      var command = BeaconCommand(
              type: BeaconCommandType.init,
              payload: {'beaconId': SystemConstantsProvider.helpScoutBeaconId})
          .toJson();
      _channel!.postMessage(command);

      if (openOnLoad == true) {
        Future.delayed(const Duration(milliseconds: 500), () {
          var command =
              const BeaconCommand(type: BeaconCommandType.open, payload: {})
                  .toJson();
          _channel!.postMessage(command);
        });
      }

      emit(state.copyWith(status: status, beaconVisible: true));
    }
  }
}
