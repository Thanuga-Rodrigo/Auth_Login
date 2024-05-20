import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_service.dart';

class HomePage extends StatelessWidget {
  final AuthService _authService = AuthService();

  Future<DocumentSnapshot> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found'));
          }

          final userData = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(userData['profile_picture_url']),
                ),
                SizedBox(height: 10),
                Text(
                  '${userData['firstName']} ${userData['lastName']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold ),
                ),
                Text(
                  '${userData['email']}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
