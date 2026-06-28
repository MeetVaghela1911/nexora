// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../../routes/app_router.dart';
// import '../auth/logic/auth_providers.dart';
//
// class SplashScreen extends ConsumerWidget {
//   const SplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authStateChangesProvider);
//
//     return authState.when(
//       data: (user) {
//         Future.microtask(() {
//           if (user != null) {
//             context.go(AppRoutes.home);
//           } else {
//             context.go(AppRoutes.login);
//           }
//         });
//         return const Scaffold(body: Center(child: CircularProgressIndicator()));
//       },
//       loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
//       error: (_, __) => const Scaffold(body: Center(child: Text('Error in auth state'))),
//     );
//   }
// }
