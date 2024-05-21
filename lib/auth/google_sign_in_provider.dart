import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_service.dart'; // Import the AuthService class

class GoogleSignInProvider {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AuthService _authService = AuthService();

  // Function to handle sign-in with Google
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // Trigger Google sign-in flow
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      // Handle if user cancels sign-in
      if (googleSignInAccount == null) {
        return null; // User cancelled the sign-in
      }

      // Retrieve Google authentication credentials
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Authenticate with Firebase using Google credentials
      final UserCredential result = await auth.signInWithCredential(credential);
      final User? user = result.user;

      // Check if user is not null and proceed with saving user data
      if (user != null) {
        // Extract user details from GoogleSignInAccount
        final firstName = googleSignInAccount.displayName?.split(' ')?.first ?? '';
        final lastName = googleSignInAccount.displayName?.split(' ')?.last ?? '';
        final email = googleSignInAccount.email;
        final photoUrl = googleSignInAccount.photoUrl;

        // Upload profile picture and save user data to Firestore
        if (photoUrl != null) {
          final profilePictureUrl = await _authService.uploadProfilePicture(user.uid, File(photoUrl));
          await _authService.addUserToFirestore(user.uid, firstName, lastName, email, profilePictureUrl);
        }

        // Navigate to home page after successful sign-in
        Navigator.pushReplacementNamed(context, '/home');
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  // Function to handle sign-out
  Future<void> signOut() async {
    try {
      await auth.signOut(); // Sign out from Firebase Authentication
      await googleSignIn.signOut(); // Sign out from Google Sign-In
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
