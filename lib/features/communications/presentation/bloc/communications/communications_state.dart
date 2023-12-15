part of 'communications_bloc.dart';

abstract class CommunicationsState extends Equatable {
  const CommunicationsState();  

  @override
  List<Object> get props => [];
}
class CommunicationsInitial extends CommunicationsState {}
