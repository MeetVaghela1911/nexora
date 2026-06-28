import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'core/local_storage/hive/chat_models.dart';
import 'core/local_storage/hive/chat_storage_service.dart';
import 'core/utility/MyInstanc.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/bloc/singup/sign_up_bloc.dart';
import 'features/models/bloc/model_list_bloc.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency injection (Firebase is initialized here)
  await setupDependencies();

  // Wait for Auth to hold
  await FirebaseAuth.instance.authStateChanges().first;

  if (kIsWeb) {
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }
  // Initialize Hive

  // Enable Hive Inspector (only in debug mode)
  if (kDebugMode) {
    Hive.openBox('debug_box'); // Required for inspector
  }

  // Register adapters
  Hive.registerAdapter(ChatAdapter());
  Hive.registerAdapter(ChatMessageAdapter());

  // Initialize storage
  await ChatStorageService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => getIt<AuthBloc>()),
        BlocProvider<ModelListBloc>(create: (context) => ModelListBloc()),
      ],
      child: MaterialApp.router(
        title: 'AI Chat App',
        routerConfig: AppRouter.router,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
