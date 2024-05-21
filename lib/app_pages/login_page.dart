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
          Text(
            'Welcome',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          LoginForm(),
          SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Not registered?"),
              TextButton(
                child: Text('Register Now'),
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Icons.login),
            label: Text('Sign in with Google'),
            onPressed: () async {
              final provider = GoogleSignInProvider();
              final user = await provider.signInWithGoogle(context);

              if (user != null) {
                // If user signed in successfully, navigate to the home page
                Navigator.of(context).pushReplacementNamed('/home');
              } else {
                // Handle sign-in failure
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to sign in with Google. Please try again.'),
                ));
              }
            },
          ),
          
        ],
      ),
    );
  }
}
