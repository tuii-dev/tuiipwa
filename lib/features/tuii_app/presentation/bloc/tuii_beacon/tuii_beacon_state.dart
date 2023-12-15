part of 'tuii_beacon_bloc.dart';

enum TuiiBeaconStatus {
  initial,
  postMessageOn,
  postMessageOff,
  messageReceivedOn,
  messageReceivedOff,
  error
}

class TuiiBeaconState extends Equatable {
  final TuiiBeaconStatus? status;
  final BeaconCommand? command;
  final bool? beaconVisible;

  const TuiiBeaconState({
    this.status,
    this.command,
    this.beaconVisible,
  });

  factory TuiiBeaconState.initial() {
    return const TuiiBeaconState(
        status: TuiiBeaconStatus.initial, beaconVisible: true);
  }

  TuiiBeaconState copyWith({
    TuiiBeaconStatus? status,
    BeaconCommand? command,
    bool? beaconVisible,
  }) {
    return TuiiBeaconState(
      status: status ?? this.status,
      command: command ?? this.command,
      beaconVisible: beaconVisible ?? this.beaconVisible,
    );
  }

  @override
  List<Object?> get props => [status, command, beaconVisible];
}
