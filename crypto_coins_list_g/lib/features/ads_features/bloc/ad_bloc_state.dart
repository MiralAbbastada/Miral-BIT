import 'package:equatable/equatable.dart';

abstract class AdState extends Equatable {
  @override
  List<Object> get props => [];
}

class AdInitial extends AdState {}
class AdLoading extends AdState {}
class AdLoaded extends AdState {
  final Map<String, dynamic> adData;

  AdLoaded(this.adData);

  @override
  List<Object> get props => [adData];
}
class AdEmpty extends AdState {}
class AdError extends AdState {
  final String message;

  AdError(this.message);

  @override
  List<Object> get props => [message];
}
