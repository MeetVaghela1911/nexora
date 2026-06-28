// profile/bloc/profile_event.dart
part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final String? name;
  final String? email;
  final String? phone;

  UpdateProfile({this.name, this.email, this.phone});
}

class UpdateProfilePhoto extends ProfileEvent {
  final String photoUrl;

  UpdateProfilePhoto({required this.photoUrl});
}