// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// class AuthService {
//   final FirebaseAuth _auth;
//   final GoogleSignIn _googleSignIn;
//
//   // Constructor with proper initialization
//   AuthService(this._auth) : _googleSignIn = GoogleSignIn();
//
//   // Alternative constructor if you want to pass GoogleSignIn instance
//   AuthService.withGoogleSignIn(this._auth, this._googleSignIn);
//
//   // Stream to listen to auth state changes
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//
//   // Email/Password Sign Up
//   Future<User?> signUp(String email, String password) async {
//     try {
//       final result = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return result.user;
//     } on FirebaseAuthException catch (e) {
//       print('Sign up error: ${e.message}');
//       rethrow;
//     } catch (e) {
//       print('Unexpected error during sign up: $e');
//       return null;
//     }
//   }
//
//   // Email/Password Login
//   Future<User?> login(String email, String password) async {
//     try {
//       final result = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return result.user;
//     } on FirebaseAuthException catch (e) {
//       print('Login error: ${e.message}');
//       rethrow;
//     } catch (e) {
//       print('Unexpected error during login: $e');
//       return null;
//     }
//   }
//
//   // Google Sign-In
//   Future<UserCredential?> signInWithGoogle() async {
//     try {
//       // Trigger the authentication flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//
//       if (googleUser == null) {
//         // User canceled the sign-in
//         print('Google sign-in was cancelled by user');
//         return null;
//       }
//
//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       // Check if we have the required tokens
//       if (googleAuth.accessToken == null || googleAuth.idToken == null) {
//         throw Exception('Failed to obtain Google authentication tokens');
//       }
//
//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       // Sign in to Firebase with the Google credential
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);
//
//       print('Successfully signed in with Google: ${userCredential.user?.email}');
//       return userCredential;
//
//     } on FirebaseAuthException catch (e) {
//       print('Firebase Auth error during Google sign-in: ${e.message}');
//       return null;
//     } catch (e) {
//       print('Error signing in with Google: $e');
//       return null;
//     }
//   }
//
//   // Sign Out
//   Future<void> logout() async {
//     try {
//       await Future.wait([
//         _auth.signOut(),
//         _googleSignIn.signOut(),
//       ]);
//       print('Successfully signed out');
//     } catch (e) {
//       print('Error during sign out: $e');
//       rethrow;
//     }
//   }
//
//   // Check if user is logged in
//   User? get currentUser => _auth.currentUser;
//
//   // Get current user's display name
//   String? get currentUserDisplayName => _auth.currentUser?.displayName;
//
//   // Get current user's email
//   String? get currentUserEmail => _auth.currentUser?.email;
//
//   // Get current user's photo URL
//   String? get currentUserPhotoURL => _auth.currentUser?.photoURL;
//
//   // Check if user is signed in
//   bool get isSignedIn => _auth.currentUser != null;
//
//   // Send password reset email
//   Future<void> sendPasswordResetEmail(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       print('Password reset email sent to $email');
//     } on FirebaseAuthException catch (e) {
//       print('Error sending password reset email: ${e.message}');
//       rethrow;
//     }
//   }
//
//   // Update user profile
//   Future<void> updateUserProfile({
//     String? displayName,
//     String? photoURL,
//   }) async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         await user.updateDisplayName(displayName);
//         await user.updatePhotoURL(photoURL);
//         await user.reload();
//         print('User profile updated successfully');
//       }
//     } catch (e) {
//       print('Error updating user profile: $e');
//       rethrow;
//     }
//   }
//
//   // Delete user account
//   Future<void> deleteAccount() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         // Sign out from Google first
//         await _googleSignIn.signOut();
//         // Delete the user account
//         await user.delete();
//         print('User account deleted successfully');
//       }
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'requires-recent-login') {
//         print('Account deletion requires recent login. Please re-authenticate.');
//         rethrow;
//       } else {
//         print('Error deleting account: ${e.message}');
//         rethrow;
//       }
//     } catch (e) {
//       print('Unexpected error deleting account: $e');
//       rethrow;
//     }
//   }
//
//   // Re-authenticate user (useful before sensitive operations)
//   Future<UserCredential?> reauthenticateWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//
//       if (googleUser == null) {
//         return null;
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final user = _auth.currentUser;
//       if (user != null) {
//         return await user.reauthenticateWithCredential(credential);
//       }
//       return null;
//     } catch (e) {
//       print('Error re-authenticating with Google: $e');
//       return null;
//     }
//   }
//
//   // Check if Google Sign-In is available
//   Future<bool> isGoogleSignInAvailable() async {
//     try {
//       return await _googleSignIn.isSignedIn();
//     } catch (e) {
//       print('Error checking Google Sign-In availability: $e');
//       return false;
//     }
//   }
//
//   // Silent sign-in (attempt to sign in without user interaction)
//   Future<UserCredential?> signInSilently() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
//
//       if (googleUser == null) {
//         return null;
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       return await _auth.signInWithCredential(credential);
//     } catch (e) {
//       print('Error during silent sign-in: $e');
//       return null;
//     }
//   }
// }
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _isGoogleSignInInitialized = false;
  GoogleSignInAccount? _currentUser;

  // Stream controller for user state changes
  final StreamController<GoogleSignInAccount?> _userController =
      StreamController<GoogleSignInAccount?>.broadcast();

  // Constructor with proper initialization
  AuthService(this._auth) : _googleSignIn = GoogleSignIn.instance {
    _initializeGoogleSignIn();
  }

  // Alternative constructor if you want to pass GoogleSignIn instance
  AuthService.withGoogleSignIn(this._auth, this._googleSignIn) {
    _initializeGoogleSignIn();
  }

  // Initialize Google Sign-In asynchronously (required in v7+)
  Future<void> _initializeGoogleSignIn() async {
    if (kIsWeb) return;
    try {
      // Initialize with server client ID (required for v7.1.0+)
      await _googleSignIn.initialize(
        // Add your server client ID here - you can get this from Firebase Console
        // serverClientId: 'YOUR_SERVER_CLIENT_ID_HERE',
      );
      _isGoogleSignInInitialized = true;
      print('Google Sign-In initialized successfully');
    } catch (e) {
      print('Failed to initialize Google Sign-In: $e');
    }
  }

  User? getCurrentUserData() {
    return _auth.currentUser;
  }

  // Ensure Google Sign-In is initialized before use
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!kIsWeb && !_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  // Update user state and notify listeners
  void _updateUser(GoogleSignInAccount? user) {
    _currentUser = user;
    _userController.add(user);
  }

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Stream to listen to Google Sign-In user changes
  Stream<GoogleSignInAccount?> get googleUserStream => _userController.stream;

  // Email/Password Sign Up
  Future<User?> signUp(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during sign up: $e');
      return null;
    }
  }

  // Email/Password Login
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected error during login: $e');
      return null;
    }
  }

  // Google Sign-In (updated for v7+)
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(
          googleProvider,
        );
        print(
          'Successfully signed in with Google Web: ${userCredential.user?.email}',
        );
        return userCredential;
      } catch (e) {
        print('Error signing in with Google Web: $e');
        return null;
      }
    }

    await _ensureGoogleSignInInitialized();

    try {
      // Authenticate with Google (throws exceptions instead of returning null)
      // Note: authenticate() is required for google_sign_in ^7.0.0
      // We rely on the google-signin-client_id meta tag in index.html for Web support.
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      // Get authorization for Firebase-required scopes
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      if (authorization == null) {
        throw Exception('Failed to obtain Google authorization');
      }

      // For Firebase, we need to get the ID token from the GoogleSignInAccount
      // The authentication property might still have the idToken
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential using authorization access token and any available ID token
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken:
            googleAuth.idToken, // This might still be available for ID tokens
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Update local user state
      _updateUser(googleUser);

      print(
        'Successfully signed in with Google: ${userCredential.user?.email}',
      );
      return userCredential;
    } on GoogleSignInException catch (e) {
      print('Google Sign-In error: ${e.code.name} - ${e.description}');
      return null;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth error during Google sign-in: ${e.message}');
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Silent sign-in (updated for v7+)
  Future<UserCredential?> signInSilently() async {
    if (kIsWeb) return null;
    await _ensureGoogleSignInInitialized();

    try {
      // Use attemptLightweightAuthentication instead of signInSilently
      final result = _googleSignIn.attemptLightweightAuthentication();

      GoogleSignInAccount? googleUser;

      // Handle both sync and async returns
      if (result is Future<GoogleSignInAccount?>) {
        googleUser = await result;
      } else {
        googleUser = result as GoogleSignInAccount?;
      }

      if (googleUser == null) {
        print('Silent sign-in returned no user');
        return null;
      }

      // Get authorization for Firebase-required scopes
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      if (authorization == null) {
        print('Failed to obtain authorization for silent sign-in');
        return null;
      }

      // Get authentication details for ID token
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Update local user state
      _updateUser(googleUser);

      print('Silent sign-in successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('Error during silent sign-in: $e');
      return null;
    }
  }

  // Sign Out (updated for v7+)
  Future<void> logout() async {
    try {
      if (kIsWeb) {
        await _auth.signOut();
      } else {
        await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
      }

      // Update local user state
      _updateUser(null);

      print('Successfully signed out');
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }

  // Check if user is logged in (manual state management in v7+)
  User? get currentUser => _auth.currentUser;
  GoogleSignInAccount? get currentGoogleUser => _currentUser;

  // Get current user's display name
  String? get currentUserDisplayName => _auth.currentUser?.displayName;

  // Get current user's email
  String? get currentUserEmail => _auth.currentUser?.email;

  // Get current user's photo URL
  String? get currentUserPhotoURL => _auth.currentUser?.photoURL;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.message}');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        await user.reload();
        print('User profile updated successfully');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Sign out from Google first
        if (!kIsWeb) {
          await _googleSignIn.signOut();
        }
        _updateUser(null);

        // Delete the user account
        await user.delete();
        print('User account deleted successfully');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
          'Account deletion requires recent login. Please re-authenticate.',
        );
        rethrow;
      } else {
        print('Error deleting account: ${e.message}');
        rethrow;
      }
    } catch (e) {
      print('Unexpected error deleting account: $e');
      rethrow;
    }
  }

  // Re-authenticate user (useful before sensitive operations)
  Future<UserCredential?> reauthenticateWithGoogle() async {
    if (kIsWeb) {
      try {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final User? user = _auth.currentUser;
        if (user != null) {
          return await user.reauthenticateWithPopup(googleProvider);
        }
        return null;
      } catch (e) {
        print('Error re-authenticating with Google Web: $e');
        return null;
      }
    }

    await _ensureGoogleSignInInitialized();

    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        throw UnsupportedError(
          'Google Sign-In authenticate method not supported on this platform',
        );
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // Get authorization for required scopes
      final authClient = _googleSignIn.authorizationClient;
      final authorization = await authClient.authorizationForScopes([
        'email',
        'profile',
      ]);

      if (authorization == null) {
        throw Exception('Failed to obtain authorization for re-authentication');
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = _auth.currentUser;
      if (user != null) {
        final result = await user.reauthenticateWithCredential(credential);
        _updateUser(googleUser);
        return result;
      }
      return null;
    } on GoogleSignInException catch (e) {
      print(
        'Error re-authenticating with Google: ${e.code.name} - ${e.description}',
      );
      return null;
    } catch (e) {
      print('Error re-authenticating with Google: $e');
      return null;
    }
  }

  // Check if Google Sign-In is initialized
  bool get isGoogleSignInInitialized => _isGoogleSignInInitialized;

  // Get access token for additional scopes
  Future<String?> getAccessTokenForScopes(List<String> scopes) async {
    await _ensureGoogleSignInInitialized();

    try {
      final authClient = _googleSignIn.authorizationClient;

      // Try to get existing authorization
      var authorization = await authClient.authorizationForScopes(scopes);

      authorization ??= await authClient.authorizeScopes(scopes);

      return authorization.accessToken;
    } catch (error) {
      print('Failed to get access token for scopes: $error');
      return null;
    }
  }

  // Helper method to handle Google Sign-In exceptions
  String googleSignInExceptionToMessage(GoogleSignInException exception) {
    switch (exception.code.name) {
      case 'canceled':
        return 'Sign-in was cancelled. Please try again if you want to continue.';
      case 'interrupted':
        return 'Sign-in was interrupted. Please try again.';
      case 'clientConfigurationError':
        return 'There is a configuration issue with Google Sign-In. Please contact support.';
      case 'providerConfigurationError':
        return 'Google Sign-In is currently unavailable. Please try again later or contact support.';
      case 'uiUnavailable':
        return 'Google Sign-In is currently unavailable. Please try again later or contact support.';
      case 'userMismatch':
        return 'There was an issue with your account. Please sign out and try again.';
      case 'unknownError':
      default:
        return 'An unexpected error occurred during Google Sign-In. Please try again.';
    }
  }

  // Dispose resources
  void dispose() {
    _userController.close();
  }
}
