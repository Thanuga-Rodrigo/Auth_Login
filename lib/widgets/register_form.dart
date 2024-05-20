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
  String _name = '';
  String _password = '';
  File? _imageFile;

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
      final user = await authService.registerWithEmail(_email, _password, _name, _imageFile!);
      if (user != null) {
        Navigator.of(context).pushReplacementNamed('/home');
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
              key: ValueKey('name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name.';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Name'),
              onSaved: (value) {
                _name = value!;
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
            SizedBox(height: 12),
            ElevatedButton(
              child: Text('Register'),
              onPressed: _trySubmit,
            ),
          ],
        ),
      ),
    );
  }
}
