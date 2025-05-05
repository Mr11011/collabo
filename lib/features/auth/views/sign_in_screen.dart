import 'package:collabo/features/auth/controller/auth_states.dart';
import 'package:collabo/features/auth/views/sign_up_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../home_screen.dart';
import '../controller/auth_cubit.dart';
import '../widgets/customTextfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  var formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.withValues(alpha: 0.8),
        title: Text("Sign In", style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/OB.png"),
              ),
            ),
          ),
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: BouncingScrollPhysics(),
            child: BlocConsumer<AuthCubit, AuthStates>(
              builder: (context, AuthStates state) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            image: const DecorationImage(
                              fit: BoxFit.contain,
                              image: AssetImage("assets/images/smile.png"),
                            ),
                          ),
                        ),
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 25),
                        CustomTextFormField(
                          labelText: "Email",
                          hintText: "Enter your email address",
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.attach_email_rounded,
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please enter your email",
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return 'Please Enter Your Email';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              Fluttertoast.showToast(
                                msg: 'Enter a valid email',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        CustomTextFormField(
                          labelText: "Password",
                          hintText: "Enter your password",
                          prefixIcon: Icons.lock,
                          obscureText: isPasswordHidden,
                          suffixIcon:
                              isPasswordHidden
                                  ? Icons.visibility_sharp
                                  : Icons.visibility_off,
                          onSuffixIconPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Enter your password",
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                            if (value!.length < 6) {
                              Fluttertoast.showToast(msg: "Password too short");
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        ConditionalBuilder(
                          builder:
                              (context) => ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    context.read<AuthCubit>().signIn(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                ),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          condition: state is! AuthLoadingState,
                          fallback:
                              (context) => const CircularProgressIndicator(),
                        ),
                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Don't have account? Sign Up",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              listener: (context, AuthStates state) {
                if (state is AuthSuccessState) {
                  Fluttertoast.showToast(
                    msg: "Login Successfully",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Colors.green,
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
                if (state is AuthErrorState) {
                  Fluttertoast.showToast(
                    msg: state.error,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.SNACKBAR,
                    backgroundColor: Colors.redAccent,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
