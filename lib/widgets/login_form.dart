import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid && !_isLoading) {
      _formKey.currentState!.save();
      final authService = AuthService();
      setState(() {
        _isLoading = true;
      });
      final user = await authService.signInWithEmail(_email, _password);
      if (user != null) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacementNamed('/home');
      }else{
        _isLoading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: ValueKey('email'),
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: 'Email address'),
              onSaved: (value) {
                _email = value!;
              },
            ),
            TextFormField(
              key: ValueKey('password'),
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'Password must be at least 6 characters long.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              onSaved: (value) {
                _password = value!;
              },
            ),
            SizedBox(height: 12),
            ElevatedButton(
              child: _isLoading ? CircularProgressIndicator() : Text('Login'), // Show loader or text based on loading state
              onPressed: _isLoading ? null : _trySubmit, // Disable button if loading
            ),
          ],
        ),
      ),
    );
  }
}
