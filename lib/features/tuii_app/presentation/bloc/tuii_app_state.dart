part of 'tuii_app_bloc.dart';

abstract class TuiiAppState extends Equatable {
  const TuiiAppState();  

  @override
  List<Object> get props => [];
}
class TuiiAppInitial extends TuiiAppState {}
