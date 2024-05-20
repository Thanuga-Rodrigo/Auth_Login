import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../auth/google_sign_in_provider.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoginForm(),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.login),
            label: Text('Sign in with Google'),
            onPressed: () async {
              final provider = GoogleSignInProvider();
              await provider.signInWithGoogle();
              Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          SizedBox(height: 10),
          TextButton(
            child: Text('Register Here'),
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
          ),
        ],
      ),
    );
  }
}
