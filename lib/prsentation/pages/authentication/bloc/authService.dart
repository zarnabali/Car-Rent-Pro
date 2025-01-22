import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign in
  Future<Either<String, String>> signInWithEmailPassword(
      String email, String password) async {
    try {
      print('Attempting to sign in with email: $email');
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      /// save user info if iy does'nt exist already
      _firebaseFirestore.collection("Users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      );

      return const Right('SignIn was Successful');
    } on FirebaseAuthException catch (e) {
      print('SignIn Error - Code: ${e.code}, Message: ${e.message}');
      String message = '';

      switch (e.code) {
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-not-found':
          message = 'No user found for this email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for this user.';
          break;
        case 'user-disabled':
          message = 'This user has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many requests. Try again later.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        case 'invalid-credential':
          message = 'Invalid credentials.';
          break;
        default:
          message = 'An unknown error occurred';
      }

      return Left(message);
    }
  }

  // Sign up
  Future<Either<String, String>> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      print('Attempting to sign up with email: $email');
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      /// save user info in a seperate doc
      _firebaseFirestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
      });

      return const Right('Signup was Successful');
    } on FirebaseAuthException catch (e) {
      print('SignUp Error - Code: ${e.code}, Message: ${e.message}');
      String message = '';

      switch (e.code) {
        case 'weak-password':
          message = 'The password is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled.';
          break;
        default:
          message = 'An unknown error occurred.';
      }

      return Left(message);
    }
  }

  //sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }
  //errors
}
