import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');
  final Reference _storageReference = FirebaseStorage.instance.ref();

   Future<User?> signInWithEmail(String email, String password) async {
  try {
    UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    User? user = result.user;

    if (user != null && !user.emailVerified) {
      await _auth.signOut(); // Sign out the user
      throw AuthException('EmailNotVerified', 'Please verify your email before logging in.');
    }

    return user;
  } on FirebaseAuthException catch (e) {
    throw AuthException('InvalidCredentials', 'Invalid email or password.');
    
  } catch (e) {
    throw AuthException('UnknownError', 'Email not verified.');
  }
}


  Future<User?> registerWithEmail(String email, String password, String firstName, String lastName, File imageFile) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      // Upload profile picture to Firebase Storage
      final profilePictureUrl = await uploadProfilePicture(userId, imageFile);

      // Add user data to Firestore
      await addUserToFirestore(userId, firstName, lastName, email, profilePictureUrl);
      await userCredential.user?.sendEmailVerification(); // Send verification email

      return userCredential.user;
    } catch (e) {
      throw AuthException('RegistrationError', e.toString());
    }
  }

   Future<String> uploadProfilePicture(String userId, File imageFile) async {
    final storageReference = _storageReference.child('$userId/profile.jpg');
    await storageReference.putFile(imageFile);
    return await storageReference.getDownloadURL();
  }

  Future<void> addUserToFirestore(String userId, String firstName, String lastName, String email, String profilePictureUrl) async {
    await _usersCollection.doc(userId).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
    });
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);
}
