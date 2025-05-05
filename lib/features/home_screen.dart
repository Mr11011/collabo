import 'package:collabo/features/auth/views/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth/controller/auth_cubit.dart';
import 'auth/controller/auth_states.dart';
import 'auth/data/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Colors.grey.shade300,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (route) => false,
              );
            },
            icon: Icon(Icons.exit_to_app_rounded),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthStates>(
        builder: (BuildContext context, state) {
          if (state is AuthSuccessState) {
            return Stack(
              children: [
                Positioned(
                  top: 20,
                  left: 50,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hello 👋',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        state.userData.username.replaceFirst(
                          state.userData.username[0],
                          state.userData.username[0].toUpperCase(),
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Text("Loading");
        },
        listener: (BuildContext context, Object? state) {},
      ),
    );
  }
}
