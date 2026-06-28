import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_router.dart';
import '../../auth/bloc/singup/sign_up_bloc.dart';
import '../../auth/bloc/singup/sign_up_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _spinController;
  late final AnimationController _logoAnimController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  bool _authCheckCompleted = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    print('🔄 SplashScreen initState called');

    // Initialize animations
    _initializeAnimations();

    // Start auth check after a brief delay to allow animations to start
    Timer(const Duration(seconds: 1), _checkAuthenticationStatus);

    // Fallback navigation timer (in case auth check fails or takes too long)
    _navigationTimer = Timer(const Duration(seconds: 5), _navigateToFallback);

    print('⏰ Auth check scheduled in 1s, fallback in 5 seconds');
  }

  void _initializeAnimations() {
    print('🎬 Initializing animations...');

    // Spinner controller
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    print('🌀 Spinner animation controller initialized');

    // Logo fade + scale controller
    _logoAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _logoAnimController,
      curve: Curves.easeInOut,
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimController, curve: Curves.easeOutBack),
    );

    _logoAnimController.forward();
    print('🎭 Logo animation started (fade + scale)');
  }

  void _checkAuthenticationStatus() {
    print('🔐 Starting authentication check...');

    try {
      // Listen to auth state changes
      final authBloc = context.read<AuthBloc>();
      print('📡 AuthBloc obtained from context');

      // Check current state first
      final currentState = authBloc.state;
      print('📊 Current AuthBloc state: ${currentState.runtimeType}');

      // IMPORTANT: Check if user is already authenticated
      // This handles the case where the app is reloaded and the user is still logged in
      if (currentState is AuthAuthenticated) {
        print('✅ User is authenticated via AuthBloc - navigating to chat');
        _navigateToHome();
        return;
      }

      // Also check the AuthBloc's currentUser directly (more reliable on reload)
      if (authBloc.isSignedIn) {
        print(
          '✅ User is signed in (checked via AuthBloc.isSignedIn) - navigating to chat',
        );
        _navigateToHome();
        return;
      }

      // If state is explicitly unauthenticated, go to onboarding
      if (currentState is AuthUnauthenticated) {
        print('❌ User is not authenticated - navigating to onboarding');
        _navigateToOnboarding();
        return;
      }

      if (currentState is AuthError) {
        print('❌ Auth error detected - navigating to onboarding');
        _navigateToOnboarding();
        return;
      }

      // State is initial or loading - wait for state change
      print('⏳ Auth state is initial/loading - setting up listener');
      _setupAuthListener();
    } catch (e) {
      print('🚨 Auth check error: $e');
      print('🔄 Falling back to onboarding due to error');
      // If there's any error, go to onboarding
      _navigateToOnboarding();
    }
  }

  void _setupAuthListener() {
    print('👂 Setting up auth state listener...');

    final authBloc = context.read<AuthBloc>();

    // Listen to state changes for a limited time
    final subscription = authBloc.stream.listen((state) {
      print('📢 Auth state changed: ${state.runtimeType}');

      if (_authCheckCompleted) {
        // print('⚠️ Auth check already completed, ignoring state change');
        return;
      }

      if (state is AuthAuthenticated) {
        print('✅ AuthAuthenticated detected - completing auth check');
        _authCheckCompleted = true;
        _navigateToHome();
      } else if (state is AuthUnauthenticated) {
        print('❌ AuthUnauthenticated detected - completing auth check');
        _authCheckCompleted = true;
        _navigateToOnboarding();
      } else if (state is AuthError) {
        print('❌ AuthError detected - completing auth check');
        _authCheckCompleted = true;
        _navigateToOnboarding();
      } else {
        print('⏳ Still waiting for auth state (current: ${state.runtimeType})');
      }
      // If state is AuthLoading or AuthInitial, we continue waiting
    });

    print('⏰ Auth listener timeout set for 5 seconds'); // Increased timeout

    // Cancel listener after timeout
    Timer(const Duration(seconds: 5), () {
      print('⏰ Auth listener timeout reached');
      subscription.cancel();
      print('🔇 Auth listener subscription cancelled');

      if (!_authCheckCompleted) {
        print(
          '🔄 Auth check not completed - navigating to onboarding as fallback',
        );
        _authCheckCompleted = true;
        _navigateToOnboarding(); // Default to onboarding if timeout
      } else {
        print('✅ Auth check already completed before timeout');
      }
    });
  }

  void _navigateToHome() {
    print('🏠 Navigating to home...');
    print('📊 Mounted: $mounted, Auth check completed: $_authCheckCompleted');

    if (!mounted) {
      print('⚠️ Widget not mounted, skipping navigation');
      return;
    }

    _navigationTimer?.cancel();
    print('🛑 Fallback navigation timer cancelled');

    // Add a small delay to ensure smooth animation
    Timer(const Duration(milliseconds: 300), () {
      print('⏳ Delayed navigation to home after 300ms');
      print('📊 Still mounted: $mounted');

      if (mounted) {
        print('🚀 Going to: ${AppRoutes.chat}');
        context.go(AppRoutes.chat); // Or your home route
      } else {
        print('⚠️ Widget unmounted during delay, navigation cancelled');
      }
    });
  }

  void _navigateToOnboarding() {
    print('🎯 Navigating to onboarding...');
    print('📊 Mounted: $mounted, Auth check completed: $_authCheckCompleted');

    if (!mounted) {
      print('⚠️ Widget not mounted, skipping navigation');
      return;
    }

    _navigationTimer?.cancel();
    print('🛑 Fallback navigation timer cancelled');

    Timer(const Duration(milliseconds: 300), () {
      print('⏳ Delayed navigation to onboarding after 300ms');
      print('📊 Still mounted: $mounted');

      if (mounted) {
        print('🚀 Going to: ${AppRoutes.onboarding}');
        context.go(AppRoutes.onboarding);
      } else {
        print('⚠️ Widget unmounted during delay, navigation cancelled');
      }
    });
  }

  void _navigateToFallback() {
    print('🔄 Fallback navigation triggered');
    print('📊 Auth check completed: $_authCheckCompleted, Mounted: $mounted');

    if (!_authCheckCompleted && mounted) {
      print('🚀 Executing fallback navigation to onboarding');
      _authCheckCompleted = true;
      context.go(AppRoutes.onboarding); // Fallback to onboarding
    } else {
      print(
        '⚠️ Fallback navigation skipped (already completed or not mounted)',
      );
    }
  }

  @override
  void dispose() {
    print('🗑️ SplashScreen dispose called');
    _spinController.dispose();
    print('🌀 Spinner animation disposed');
    _logoAnimController.dispose();
    print('🎭 Logo animation disposed');
    _navigationTimer?.cancel();
    print('⏰ Navigation timer cancelled');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building SplashScreen UI');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;
    print('🎨 Theme: ${isDark ? "Dark" : "Light"}');

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: colors.colorAccent,
        // statusBarColor: colors.background
      ),
    );

    final bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [colors.colorPrimary, colors.colorAccent],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: Stack(
          children: [
            // Center animated custom paint
            Center(
              child: AnimatedBuilder(
                animation: _spinController,
                builder: (_, __) {
                  return CustomPaint(
                    painter: _BigEyeLoaderPainter(
                      progress: _spinController.value,
                      colors: colors,
                    ),
                    size: const Size.square(0),
                  );
                },
              ),
            ),

            // Center logo with fade + scale
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500),
                      color: colors.background,
                    ),
                    child: Image.asset(
                      'assets/logo/nexora-logo.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom spinner + text
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _spinController,
                    builder: (_, __) {
                      return CustomPaint(
                        painter: _RingSpinnerPainter(
                          angle: _spinController.value * 2 * math.pi,
                          colors: colors,
                        ),
                        size: const Size.square(75),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Checking authentication...', // Updated text
                    style: TextStyle(
                      color: colors.background,
                      fontSize: 18,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter for the big center graphic
class _BigEyeLoaderPainter extends CustomPainter {
  final double progress; // 0..1
  final AppColorScheme colors;
  _BigEyeLoaderPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final outerStroke = 5.0;
    final outerR = size.width / 2 - outerStroke / 2;

    // Outer subtle ring
    final ringPaint = Paint()
      ..color = colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerStroke;
    canvas.drawCircle(c, outerR, ringPaint);

    // Right-side thick arc
    final arcPaint = Paint()
      ..color = colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    final start = -math.pi / 6 + progress * 2 * math.pi;
    const sweep = math.pi / 2.2;
    final arcRect = Rect.fromCircle(center: c, radius: outerR - 14);
    canvas.drawArc(arcRect, start, sweep, false, arcPaint);

    // Eye mark in the center
    _drawEye(canvas, c, size.width);
  }

  void _drawEye(Canvas canvas, Offset center, double boxW) {
    final eyeW = boxW * 0.33;
    final eyeH = eyeW * 0.34;

    final path = Path()
      ..moveTo(center.dx - eyeW / 2, center.dy)
      ..quadraticBezierTo(
        center.dx,
        center.dy - eyeH,
        center.dx + eyeW / 2,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx,
        center.dy + eyeH,
        center.dx - eyeW / 2,
        center.dy,
      )
      ..close();

    final eyePaint = Paint()..color = colors.white;
    canvas.drawPath(path, eyePaint);

    // Two dots inside
    final dotPaint = Paint()..color = colors.colorAccent;
    final r = eyeH * 0.30;
    final dx = eyeW * 0.18;
    canvas.drawCircle(Offset(center.dx - dx, center.dy), r, dotPaint);
    canvas.drawCircle(Offset(center.dx + dx, center.dy), r, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _BigEyeLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Painter for the bottom thin ring spinner
class _RingSpinnerPainter extends CustomPainter {
  final double angle;
  final AppColorScheme colors;
  _RingSpinnerPainter({required this.angle, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    const stroke = 4.0;
    final r = size.width / 2 - stroke / 2;

    // Faint base ring
    final base = Paint()
      ..color = colors.background.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(c, r, base);

    // Bright moving wedge
    final wedge = Paint()
      ..color = colors.background
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    const sweep = math.pi / 4;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(rect, angle, sweep, false, wedge);
  }

  @override
  bool shouldRepaint(covariant _RingSpinnerPainter oldDelegate) =>
      oldDelegate.angle != angle;
}
