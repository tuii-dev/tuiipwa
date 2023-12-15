part of 'tuii_app_link_bloc.dart';

abstract class TuiiAppLinkEvent extends Equatable {
  const TuiiAppLinkEvent();

  @override
  List<Object?> get props => [];
}

class AddAppLinkCommandEvent extends TuiiAppLinkEvent {
  final String key;
  const AddAppLinkCommandEvent({
    required this.key,
  });

  @override
  List<Object?> get props => [key];
}

class UpdateAppLinkCommandEvent extends TuiiAppLinkEvent {
  final TuiiAppLinkStatus status;
  final AppLinkCommandModel appLinkCommand;
  const UpdateAppLinkCommandEvent({
    required this.status,
    required this.appLinkCommand,
  });

  @override
  List<Object?> get props => [status];
}

class ClearAppLinkCommandEvent extends TuiiAppLinkEvent {
  final String key;
  const ClearAppLinkCommandEvent({
    required this.key,
  });

  @override
  List<Object?> get props => [key];
}
