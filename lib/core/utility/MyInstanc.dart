import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../features/auth/bloc/singup/sign_up_bloc.dart';
import '../service/auth_service.dart';
import '../service/firestore_chat_service.dart';

import '../../firebase_options.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // 🔑 Make sure Firebase is initialized first
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  // Firebase singletons
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Your AuthService
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<FirebaseAuth>()),
  );

  // Firestore Chat Service for cloud storage
  getIt.registerLazySingleton<FirestoreChatService>(
    () =>
        FirestoreChatService(getIt<FirebaseFirestore>(), getIt<FirebaseAuth>()),
  );

  // Your AuthBloc
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authService: getIt<AuthService>()),
  );
}
