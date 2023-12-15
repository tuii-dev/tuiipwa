part of 'tuii_beacon_bloc.dart';

abstract class TuiiBeaconEvent extends Equatable {
  const TuiiBeaconEvent();

  @override
  List<Object?> get props => [];
}

class InitBeaconCommandChannelEvent extends TuiiBeaconEvent {}

class OutgoingBeaconCommandEvent extends TuiiBeaconEvent {
  final BeaconCommand command;
  const OutgoingBeaconCommandEvent({
    required this.command,
  });

  @override
  List<Object?> get props => [command];
}

class IncomingBeaconCommandEvent extends TuiiBeaconEvent {
  final BeaconCommand command;
  const IncomingBeaconCommandEvent({
    required this.command,
  });

  @override
  List<Object?> get props => [command];
}

class ShowBeaconCommandEvent extends TuiiBeaconEvent {
  final bool? openOnLoad;
  const ShowBeaconCommandEvent({this.openOnLoad = false});

  @override
  List<Object?> get props => [openOnLoad];
}

class HideBeaconCommandEvent extends TuiiBeaconEvent {
  const HideBeaconCommandEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticleCommandEvent extends TuiiBeaconEvent {
  final BeaconArticleType article;

  const LoadArticleCommandEvent({required this.article});

  @override
  List<Object?> get props => [article];
}
