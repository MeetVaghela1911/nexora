// profile/bloc/profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nexora/core/utility/MyInstanc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final User user;

  ProfileBloc({required this.user}) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UpdateProfilePhoto>(_onUpdateProfilePhoto);
  }

  void _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      User? user = getIt<FirebaseAuth>().currentUser;
      final userData = {
        'name': user?.displayName ?? 'User',
        'email': user?.email ?? '',
        'photoUrl': user?.photoURL,
        'phoneNo': user?.phoneNumber ?? 'No Mobile Number',
      };
      emit(ProfileLoaded(userData));
    } catch (e) {
      emit(ProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  void _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      // Update display name
      if (event.name != null && event.name!.isNotEmpty) {
        await user.updateDisplayName(event.name);
      }

      // Update email if provided and different
      if (event.email != null && event.email!.isNotEmpty && event.email != user.email) {
        await user.updateEmail(event.email!);
      }

      await user.reload();
      final updatedUser = FirebaseAuth.instance.currentUser;

      final userData = {
        'name': updatedUser?.displayName ?? 'User',
        'email': updatedUser?.email ?? '',
        'photoUrl': updatedUser?.photoURL,
        'phoneNo': updatedUser?.phoneNumber ?? 'No Mobile Number',
      };
      emit(ProfileLoaded(userData));
    } catch (e) {
      emit(ProfileError('Failed to update profile: ${e.toString()}'));
    }
  }

  void _onUpdateProfilePhoto(UpdateProfilePhoto event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await user.updatePhotoURL(event.photoUrl);
      await user.reload();

      final updatedUser = FirebaseAuth.instance.currentUser;
      final userData = {
        'name': updatedUser?.displayName ?? 'User',
        'email': updatedUser?.email ?? '',
        'photoUrl': updatedUser?.photoURL,
        'phoneNo': updatedUser?.phoneNumber ?? 'No Mobile Number',
      };
      emit(ProfileLoaded(userData));
    } catch (e) {
      emit(ProfileError('Failed to update photo: ${e.toString()}'));
    }
  }
}