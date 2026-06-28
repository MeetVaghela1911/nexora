// profile/bloc/profile_state.dart
part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;

  ProfileLoaded(this.userData);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}