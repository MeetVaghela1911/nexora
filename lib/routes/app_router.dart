// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import '../features/splash/presentation/splash_screen.dart';
// import '../features/onboarding/presentation/onboarding_screen.dart';
// import '../features/auth/presentation/login_screen.dart';
// import '../features/auth/presentation/signup_screen.dart';
// import '../features/home/presentation/home_screen.dart';
// import '../features/models/presentation/model_list_screen.dart';
// import '../features/history/presentation/history_screen.dart';
// import '../features/profile/presentation/profile_screen.dart';
// import '../features/settings/presentation/settings_screen.dart';
// import '../features/splash/presentation/welcome_screen.dart';
// import '../features/sync/presentation/sync_screen.dart';
// import '../features/common/presentation/empty_error_screen.dart';
//
// class AppRoutes {
//   static const splash = '/';
//   static const onboarding = '/onboarding';
//   static const login = '/login';
//   static const signup = '/signup';
//   static const home = '/home';
//   static const models = '/models';
//   static const history = '/history';
//   static const profile = '/profile';
//   static const settings = '/settings';
//   static const sync = '/sync';
//   static const empty = '/empty';
// }
//
// class AppRouter {
//   static final GoRouter router = GoRouter(
//     initialLocation: AppRoutes.splash,
//     routes: <RouteBase>[
//       GoRoute(path: AppRoutes.splash, pageBuilder: (c,s) => _animatedPage(const SplashScreen())),
//       GoRoute(path: AppRoutes.onboarding, pageBuilder: (c,s) => _animatedPage(const WelcomeScreen())),
//       GoRoute(path: AppRoutes.login, pageBuilder: (c,s) => _animatedPage(const LoginScreen())),
//       GoRoute(path: AppRoutes.signup, pageBuilder: (c,s) => _animatedPage(const SignupScreen())),
//       GoRoute(path: AppRoutes.home, pageBuilder: (c,s) => _animatedPage(const HomeScreen())),
//       GoRoute(path: AppRoutes.models, pageBuilder: (c,s) => _animatedPage(const ModelListScreen())),
//       GoRoute(path: AppRoutes.history, pageBuilder: (c,s) => _animatedPage(const HistoryScreen())),
//       GoRoute(path: AppRoutes.profile, pageBuilder: (c,s) => _animatedPage(const ProfileScreen())),
//       GoRoute(path: AppRoutes.settings, pageBuilder: (c,s) => _animatedPage(const SettingsScreen())),
//       GoRoute(path: AppRoutes.sync, pageBuilder: (c,s) => _animatedPage(const SyncScreen())),
//       GoRoute(path: AppRoutes.empty, pageBuilder: (c,s) => _animatedPage(const EmptyErrorScreen())),
//     ],
//   );
//
//   // Animated slide transition
//   static CustomTransitionPage _animatedPage(Widget child) {
//     return CustomTransitionPage(
//       key: ValueKey(child.hashCode),
//       child: child,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0); // from right
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//
//         final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         final offsetAnimation = animation.drive(tween);
//
//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     );
//   }
// }

import 'package:nexora/features/about/presentation/about_screen.dart';
import 'package:nexora/features/chat/presentation/chat_screen.dart';
import 'package:nexora/features/profile/presentation/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/splash/presentation/splash_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/models/presentation/model_list_screen.dart';
import '../features/history/presentation/history_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/splash/presentation/welcome_screen.dart';
import '../features/sync/presentation/sync_screen.dart';
import '../features/common/presentation/empty_error_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const chat = '/chat';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const models = '/models';
  static const history = '/history';
  static const profile = '/profile';
  static const editProfile = '/editProfile';
  static const settings = '/settings';
  static const sync = '/sync';
  static const empty = '/empty';
  static const about = '/about';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;

      // Get the current location
      final isGoingToAuth =
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;

      final isGoingToChat = state.matchedLocation == AppRoutes.chat;

      // If authenticated and trying to go to auth screens, redirect to chat
      if (isAuthenticated && isGoingToAuth) {
        print(
          '🔄 User is authenticated, redirecting from ${state.matchedLocation} to chat',
        );
        return AppRoutes.chat;
      }

      // If not authenticated and trying to go to chat, redirect to splash
      if (!isAuthenticated && isGoingToChat) {
        print('🔄 User is not authenticated, redirecting from chat to splash');
        return AppRoutes.splash;
      }

      // No redirect needed
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (c, s) => _animatedPage(const SplashScreen()),
      ),
      // GoRoute(path: AppRoutes.splash, pageBuilder: (c,s) => _animatedPage(const CategoryPage())),
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (c, s) => _animatedPage(const ChatScreen()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (c, s) => _animatedPage(const WelcomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (c, s) => _animatedPage(const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (c, s) => _animatedPage(const SignupScreen()),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (c, s) => _animatedPage(const HomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.models,
        pageBuilder: (c, s) => _animatedPage(const ModelListScreen()),
      ),
      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (c, s) => _animatedPage(const HistoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (c, s) => _animatedPage(const ProfileScreen()),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (c, s) => _animatedPage(const EditProfileScreen()),
        // builder: (c, s) => EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        pageBuilder: (c, s) => _animatedPage(const SettingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.sync,
        pageBuilder: (c, s) => _animatedPage(const SyncScreen()),
      ),
      GoRoute(
        path: AppRoutes.empty,
        pageBuilder: (c, s) => _animatedPage(const EmptyErrorScreen()),
      ),
      GoRoute(
        path: AppRoutes.about,
        pageBuilder: (c, s) => _animatedPage(AboutScreen()),
      ),
    ],
  );

  // Slide + fade transition
  static CustomTransitionPage _animatedPage(Widget child) {
    return CustomTransitionPage(
      key: ValueKey(child.hashCode),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from right
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        // Fade in
        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  // static CustomTransitionPage _animatedPage(Widget child) {
  //   return CustomTransitionPage(
  //     key: ValueKey(child.hashCode),
  //     child: child,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       const begin = Offset(1.0, 0.0); // from right
  //       const end = Offset.zero;
  //       const curve = Curves.easeInOut;
  //
  //       final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //       final offsetAnimation = animation.drive(tween);
  //
  //       return SlideTransition(
  //         position: offsetAnimation,
  //         child: child,
  //       );
  //     },
  //   );
  // }
}
