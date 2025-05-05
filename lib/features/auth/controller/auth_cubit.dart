import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_model.dart';
import 'auth_states.dart';

class AuthCubit extends Cubit<AuthStates> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthCubit({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       super(AuthInitState());

  // Signs up a new user with email, password, username, title, and phone
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
    required String title,
    required String phone,
  }) async {
    emit(AuthLoadingState());
    User? user;

    try {
      // Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      if (user == null) {
        emit(AuthErrorState("User creation failed"));
        return;
      }

      // Create UserData instance
      final userData = UserData(
        uid: user.uid,
        email: email,
        username: username,
        title: title,
        phone: phone,
        profilePictureUrl: null,
        createdAt: Timestamp.now(),
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(user.uid).set(userData.toMap());

      emit(AuthSuccessState(user, userData));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with that email';
          break;
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        default:
          message = 'Registration failed: ${e.code}';
      }
      emit(AuthErrorState(message));
      if (kDebugMode) debugPrint('Auth Error: $message');
    } catch (e) {
      // Delete auth user if Firestore write fails
      if (user != null) {
        await user.delete();
      }
      emit(AuthErrorState('Registration failed. Please try again'));
      if (kDebugMode) debugPrint('Unexpected Error: $e');
    }
  }

  // Signs in an existing user
  Future<void> signIn(String email, String password) async {
    emit(AuthLoadingState());
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        emit(AuthErrorState("User not found"));
        return;
      }

      // Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _firebaseAuth.signOut();
        emit(AuthErrorState("User profile not found"));
        return;
      }
      final userData = UserData.fromMap(userDoc.data() as Map<String, dynamic>);

      // Emit success with user data
      emit(AuthSuccessState(user, userData));
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email format';
          break;
        case 'user-disabled':
          message = 'Account disabled';
          break;
        case 'user-not-found':
          message = 'No account found';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;
        default:
          message = 'Login failed: ${e.code}';
      }
      emit(AuthErrorState(message));
      if (kDebugMode) debugPrint('Auth Error: $message');
    } catch (e) {
      emit(AuthErrorState('An unexpected error occurred'));
      if (kDebugMode) debugPrint('Unexpected Error: $e');
    }
  }

  // Signs out the current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      emit(AuthSignOutState());
    } catch (e) {
      emit(AuthErrorState('Failed to sign out'));
      if (kDebugMode) debugPrint('Sign Out Error: $e');
    }
  }

  // Checks the current auth state on app start
  Future<void> checkAuthState() async {
    emit(AuthLoadingState());
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      emit(AuthSignOutState());
      return;
    }

    // Fetch user data from Firestore
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _firebaseAuth.signOut();
        emit(AuthSignOutState());
        return;
      }
      final userData = UserData.fromMap(userDoc.data() as Map<String, dynamic>);
      emit(AuthSuccessState(user, userData));
    } catch (e) {
      emit(AuthErrorState('Failed to load user data'));
      if (kDebugMode) debugPrint('Check Auth Error: $e');
    }
  }
}
