// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:indoor_nav/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SignInPage({super.key});

  Future<User?> _handleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) {
        // The user canceled the sign-in process
        return null;
      }

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
    print("User Sign Out");
  }

  Future<void> storeUserData(User user) async {
    final CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      await users.doc(user.uid).set({
        'uid': user.uid,
        'lastSignInTime': user.metadata.lastSignInTime,
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,      
        // Add any other user information you want to store here
      });
    } catch (error) {
      print('Error storing user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final user = await _handleSignIn();
            if (user != null) {
              // Successfully signed in
              print('Signed in: ${user.displayName}');

              await storeUserData(user);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            } else {
              // Sign-in failed
              print('Sign-in failed.');
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
