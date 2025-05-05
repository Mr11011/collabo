import 'package:collabo/features/auth/data/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthStates {}

class AuthInitState extends AuthStates {}

class AuthLoadingState extends AuthStates {}

class AuthSuccessState extends AuthStates {
  final User user;
  final UserData userData;

  AuthSuccessState(this.user, this.userData);
}

class AuthErrorState extends AuthStates {
  final String error;

  AuthErrorState(this.error);
}

class AuthSignOutState extends AuthStates {}