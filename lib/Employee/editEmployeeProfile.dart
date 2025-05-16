import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class editEmployeeProfile extends StatefulWidget {
  const editEmployeeProfile({required this.employeeID, super.key});
  final int employeeID;

  @override
  State<editEmployeeProfile> createState() => _editEmployeeProfileState();
}

class _editEmployeeProfileState extends State<editEmployeeProfile> {
  final CollectionReference employees = FirebaseFirestore.instance.collection('Employees');

  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _newImageFile;
  String profilePicture = '';
  String? docId;

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  Future<void> fetchEmployeeData() async {
    try {
      QuerySnapshot querySnapshot = await employees
          .where('employeeID', isEqualTo: widget.employeeID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        docId = doc.id;

        setState(() {
          addressController.text = data['address'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phoneNumber'] ?? '';
          passwordController.text = data['password'] ?? '';
          profilePicture = data['profilePicture'] ?? '';
        });
      } else {
        print("No matching employee found!");
      }
    } catch (e) {
      print("Error fetching employee data: $e");
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _newImageFile = pickedFile;
      });
    }
  }

  Future<void> updateEmployeeData() async {
    try {
      if (docId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No employee found to update.")),
        );
        return;
      }

      final docRef = employees.doc(docId);

      await docRef.update({
        'address': addressController.text.trim(),
        'email': emailController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'password': passwordController.text.trim(),
      });

      // Upload profile picture if a new one is picked
      if (_newImageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('employee_images/$docId.jpg');

        final uploadTask = await storageRef.putFile(File(_newImageFile!.path));
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        await docRef.update({'profilePicture': downloadUrl});
        profilePicture = downloadUrl;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      print("Error updating employee data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider displayImage = _newImageFile != null
        ? FileImage(File(_newImageFile!.path))
        : profilePicture.startsWith('http')
        ? NetworkImage(profilePicture)
        : AssetImage('assets/images/$profilePicture') as ImageProvider;

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
                const SizedBox(width: 10),
                const Text("Edit Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: displayImage,
                    child: (_newImageFile == null && profilePicture.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text("Change Picture"),
                  ),
                  const SizedBox(height: 10),

                  _buildTextField("Address", addressController),
                  _buildTextField("Email", emailController),
                  _buildTextField("Phone Number", phoneController),
                  _buildTextField("Password", passwordController, isPassword: true),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: updateEmployeeData,
                    child: const Text("Confirm", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
