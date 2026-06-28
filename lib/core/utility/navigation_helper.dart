import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation helper that adapts based on platform
/// - Web: Uses context.go() to update browser URL
/// - Mobile: Uses context.push() for proper stack navigation
class NavigationHelper {
  // Store callbacks for web platform
  static final Map<String, List<VoidCallback>> _webCallbacks = {};

  /// Navigate to a route with platform-aware behavior
  ///
  /// On web: Uses go() to update URL
  /// On mobile: Uses push() for stack-based navigation
  static void navigateTo(BuildContext context, String route) {
    if (kIsWeb) {
      context.go(route);
    } else {
      context.push(route);
    }
  }

  /// Navigate to a route and execute callback on return
  ///
  /// **Mobile**: Uses push() and executes callback when returning via .then()
  /// **Web**: Uses go() and registers callback to be executed when screen is revisited
  ///
  /// Example:
  /// ```dart
  /// NavigationHelper.navigateToWithCallback(
  ///   context,
  ///   AppRoutes.editProfile,
  ///   () {
  ///     // Reload profile data
  ///     context.read<ProfileBloc>().add(LoadProfile());
  ///   },
  /// );
  /// ```
  static Future<void> navigateToWithCallback(
    BuildContext context,
    String route,
    VoidCallback? onReturn,
  ) async {
    if (kIsWeb) {
      // On web, register the callback to be called when returning to current route
      final currentRoute = GoRouterState.of(context).matchedLocation;
      if (onReturn != null) {
        _webCallbacks.putIfAbsent(currentRoute, () => []).add(onReturn);
      }
      context.go(route);
    } else {
      // On mobile, use traditional push with .then()
      await context.push(route);
      onReturn?.call();
    }
  }

  /// Execute pending callbacks for the current route (Web only)
  ///
  /// Call this in your screen's initState or didChangeDependencies
  /// to execute any pending callbacks registered before navigation.
  ///
  /// Example in your screen:
  /// ```dart
  /// @override
  /// void didChangeDependencies() {
  ///   super.didChangeDependencies();
  ///   NavigationHelper.executePendingCallbacks(context);
  /// }
  /// ```
  static void executePendingCallbacks(BuildContext context) {
    if (!kIsWeb) return; // Only needed on web

    final currentRoute = GoRouterState.of(context).matchedLocation;
    final callbacks = _webCallbacks.remove(currentRoute);

    if (callbacks != null) {
      for (final callback in callbacks) {
        callback();
      }
    }
  }

  /// Navigate and replace current route
  /// Works the same on both platforms
  static void navigateReplace(BuildContext context, String route) {
    context.pushReplacement(route);
  }

  /// Go back to previous route
  ///
  /// On web: Uses go() to navigate back (updates URL)
  /// On mobile: Uses pop() for stack-based back navigation
  static void goBack(BuildContext context) {
    if (kIsWeb) {
      // On web, we need to navigate to the previous route
      // This is a simplified version - you might want to track history
      context.pop();
    } else {
      context.pop();
    }
  }

  /// Clear all pending callbacks (useful for cleanup)
  static void clearAllCallbacks() {
    _webCallbacks.clear();
  }

  /// Clear callbacks for a specific route
  static void clearCallbacksForRoute(String route) {
    _webCallbacks.remove(route);
  }
}
