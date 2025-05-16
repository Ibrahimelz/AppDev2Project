import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterClientPage extends StatefulWidget {
  const RegisterClientPage({super.key});

  @override
  State<RegisterClientPage> createState() => _RegisterClientPageState();
}

class _RegisterClientPageState extends State<RegisterClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isMember = true;
  String? _selectedGender;
  File? _profileImage;

  final CollectionReference clients = FirebaseFirestore.instance.collection('Clients');

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture is required.')),
      );
    }
  }

  Future<String?> _uploadProfileImage(String docId) async {
    try {
      if (_profileImage == null) {
        print('No image selected.');
        return null;
      }

      final fileExists = await _profileImage!.exists();
      if (!fileExists) {
        print('Image file does not exist at path: ${_profileImage!.path}');
        return null;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('client_images/$docId.jpg');

      print('Uploading image to: client_images/$docId.jpg');
      final uploadTask = await storageRef.putFile(_profileImage!);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('Upload successful, download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }


  void _clearForm() {
    _formKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _ageController.clear();
    _descriptionController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _isMember = true;
      _selectedGender = null;
      _profileImage = null;
    });
  }

  Future<void> _registerClient() async {
    if (_formKey.currentState!.validate()) {
      if (_profileImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please capture a profile picture')),
        );
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a gender')),
        );
        return;
      }

      final docRef = await clients.add({
        'fname': _firstNameController.text.trim(),
        'lname': _lastNameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _selectedGender,
        'description': _descriptionController.text.trim(),
        'isMember': _isMember,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final imageUrl = await _uploadProfileImage(docRef.id);
      if (imageUrl != null) {
        await docRef.update({'profileImage': imageUrl});
      }

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client registered successfully')),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'MyFont'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Client', style: TextStyle(fontFamily: 'MyFont')),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                    _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                    backgroundColor: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Tap to capture profile picture (Required)',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: _inputDecoration('First Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: _inputDecoration('Last Name'),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                decoration: _inputDecoration('Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('Gender', style: TextStyle(fontFamily: 'MyFont')),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Male'),
                    selected: _selectedGender == 'Male',
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = 'Male';
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Female'),
                    selected: _selectedGender == 'Female',
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = 'Female';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Membership Status:', style: TextStyle(fontFamily: 'MyFont')),
                  const SizedBox(width: 10),
                  Switch(
                    value: _isMember,
                    onChanged: (value) {
                      setState(() {
                        _isMember = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _registerClient,
                child: const Text(
                  'Register Client',
                  style: TextStyle(fontSize: 16, fontFamily: 'MyFont', color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
