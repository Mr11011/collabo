import 'package:collabo/features/workspace/controller/workspace_cubit.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/blocObserver.dart';
import 'core/di.dart';
import 'features/auth/controller/auth_cubit.dart';
import 'features/auth/controller/auth_states.dart';
import 'features/auth/views/sign_in_screen.dart';
import 'features/boards/controller/board_cubit.dart';
import 'features/home_screen.dart';
import 'features/task/controller/task_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();

  await init();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder:
          (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create:
                    (BuildContext context) => sl<AuthCubit>()..checkAuthState(),
              ),
              BlocProvider(
                create: (BuildContext context) => sl<WorkSpaceCubit>(),
              ),
              BlocProvider(
                create: (BuildContext context) => sl<BoardCubit>(),
              ),

              BlocProvider(
                create: (BuildContext context) => sl<TaskCubit>(),
              ),
            ],
            child: const MyApp(),
          ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: DevicePreview.appBuilder,
      theme: ThemeData(fontFamily: GoogleFonts.kanit().fontFamily),
      debugShowCheckedModeBanner: false,
      home: BlocBuilder<AuthCubit, AuthStates>(
        builder: (context, state) {
          if (state is AuthSuccessState) {
            return const HomeScreen();
          } else if (state is AuthLoadingState) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return const SignInScreen();
          }
        },
      ),
    );
  }
}
