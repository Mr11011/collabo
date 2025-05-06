import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../features/auth/controller/auth_cubit.dart';
import '../features/workspace/controller/workspace_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Firebase Auth (singleton)
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // FirebaseFirestore (singleton)
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // AuthCubit
  sl.registerSingleton<AuthCubit>(
    AuthCubit(firebaseAuth: sl<FirebaseAuth>(), firestore: sl<FirebaseFirestore>()),
  );

  // WorkSpaceCubit
  sl.registerFactory<WorkSpaceCubit>(
    () => WorkSpaceCubit(
      firebaseAuth: sl<FirebaseAuth>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );
}
