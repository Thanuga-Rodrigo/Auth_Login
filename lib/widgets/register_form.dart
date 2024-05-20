import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../auth/auth_service.dart';

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _password = '';
  File? _imageFile;
  String? _errorMessage;
  bool _isLoading = false;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = File(pickedImage!.path);
    });
  }

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid && _imageFile != null) {
      _formKey.currentState!.save();
      final authService = AuthService();
      setState(() {
        _isLoading = true;
      });
      try {
        final user = await authService.registerWithEmail(_email, _password, _firstName, _lastName, _imageFile!);
        if (user != null) {
          // Registration successful
          setState((){
            _errorMessage = null;
            _isLoading = false;
          });
          _showSuccessMessage();
          // Navigate to login page
          Navigator.of(context).pushReplacementNamed('/login');
        }
      } catch (e) {
        // Handle Firebase auth exceptions
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Registration successful!'),
        duration: Duration(seconds: 2),
      ),
    );
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
              key: ValueKey('Firstname'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'First Name'),
              onSaved: (value) {
                _firstName = value!;
              },
            ),
            TextFormField(
              key: ValueKey('Lastname'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Last Name'),
              onSaved: (value) {
                _lastName = value!;
              },
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _imageFile == null
                    ? Text('No Image Selected')
                    : CircleAvatar(
                        backgroundImage: FileImage(_imageFile!),
                        radius: 40,
                      ),
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text('Add Image'),
                  onPressed: _pickImage,
                ),
              ],
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 12),
            ElevatedButton(
              child: _isLoading ? CircularProgressIndicator() : Text('Register'), // Show loader or text based on loading state
              onPressed: _isLoading ? null : _trySubmit, // Disable button if loading
            ),
          ],
        ),
      ),
    );
  }
}
