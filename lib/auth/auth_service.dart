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
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
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
      final profilePictureUrl = await _uploadProfilePicture(userId, imageFile);

      // Add user data to Firestore
      await _addUserToFirestore(userId, firstName, lastName, email, profilePictureUrl);

      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

   Future<String> _uploadProfilePicture(String userId, File imageFile) async {
    final storageReference = _storageReference.child('$userId/profile.jpg');
    await storageReference.putFile(imageFile);
    return await storageReference.getDownloadURL();
  }

  Future<void> _addUserToFirestore(String userId, String firstName, String lastName, String email, String profilePictureUrl) async {
    await _usersCollection.doc(userId).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profile_picture_url': profilePictureUrl,
    });
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
