import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/service/auth_service.dart';
import 'sign_up_event.dart';
import 'sign_up_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({required AuthService authService})
    : _authService = authService,
      super(AuthInitial()) {
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<SignUpRequested>(_onSignUpRequested);
    on<LoginRequested>(_onLoginRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);

    // Check initial state
    final user = _authService.currentUser;
    if (user != null) {
      add(AuthStatusChanged(user));
    }

    // Listen to auth state changes
    _initializeAuthListener();
  }

  void _initializeAuthListener() {
    try {
      _authSubscription = _authService.authStateChanges.listen((user) {
        add(AuthStatusChanged(user));
      });
    } catch (e) {
      print('Auth stream error: $e');
      // Emit initial unauthenticated state if stream fails
      add(const AuthStatusChanged(null));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signUp(event.email, event.password);
      if (user != null) {
        // Update display name for the newly created user
        await _authService.updateUserProfile(displayName: event.name);
        // Note: State will be updated by the auth stream listener
        // We don't emit AuthAuthenticated here to avoid race conditions
      } else {
        emit(const AuthError('Failed to create account. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getFirebaseAuthErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(event.email, event.password);
      if (user == null) {
        emit(
          const AuthError('Failed to sign in. Please check your credentials.'),
        );
      }
      // State will be updated by the auth stream listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getFirebaseAuthErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential == null) {
        emit(const AuthError('Google sign-in was cancelled or failed.'));
      }
      // State will be updated by the auth stream listener
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getFirebaseAuthErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError('Google sign-in failed: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.logout();
      // State will be updated by the auth stream listener
    } catch (e) {
      emit(AuthError('Failed to sign out: ${e.toString()}'));
    }
  }

  void _onAuthStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address. Please try logging in.';
      case 'user-not-found':
        return 'No account found with this email address. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid. Please check your email.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'The authentication credential is invalid or has expired.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email but different sign-in method.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }

  // Helper method to get current user
  User? get currentUser => _authService.currentUser;

  // Helper method to check if user is signed in
  bool get isSignedIn => _authService.isSignedIn;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
