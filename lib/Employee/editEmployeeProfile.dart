import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class editEmployeeProfile extends StatefulWidget {
  const editEmployeeProfile({required this.employeeID ,super.key});

  final int employeeID;

  @override
  State<editEmployeeProfile> createState() => _editEmployeeProfileState();
}

class _editEmployeeProfileState extends State<editEmployeeProfile> {

  final CollectionReference employees = FirebaseFirestore.instance.collection('Employees');

  Future<void> fetchEmployeeData() async {
    try {
      QuerySnapshot querySnapshot = await employees
          .where('employeeID', isEqualTo: widget.employeeID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          addressController.text = data['address'] ?? '';
          emailController.text = data['email'] ?? '';
          phoneController.text = data['phoneNumber'] ?? '';
          passwordController.text = data['password'] ?? '';
          profilePicture = data['profilePicture'];
        });
      } else {
        print("No matching employee found!");
      }
    } catch (e) {
      print("Error fetching employee data: $e");
    }
  }

  Future<void> updateEmployeeData() async {
    try {
      // Get the document with matching employeeID
      QuerySnapshot querySnapshot = await employees
          .where('employeeID', isEqualTo: widget.employeeID)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docRef = querySnapshot.docs.first.reference;

        await docRef.update({
          'address': addressController.text.trim(),
          'email': emailController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'password': passwordController.text.trim(),
          // Add 'profilePicture' if it's editable too
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
      } else {
        print("No matching employee found.");
      }
    } catch (e) {
      print("Error updating employee data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile.")),
      );
    }
  }



  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String profilePicture= '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEmployeeData();
  }

  @override
  Widget build(BuildContext context) {
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
    backgroundImage: AssetImage('assets/images/$profilePicture'), // Replace with your image asset or network
    ),
    TextButton(
    onPressed: () {
    // Handle change picture
    },
    child: const Text("Change Picture"),
    ),

      const SizedBox(height: 10),
            Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Address", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: addressController,
                obscureText: false,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              obscureText: false,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("PhoneNumber", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: phoneController,
              obscureText: false,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Password", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 30),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          updateEmployeeData();
        },
        child: const Text("Confirm", style: TextStyle(fontSize: 16)),
      ),
      const SizedBox(height: 30),
    ]
    )
        )
        )

        ],
      ),
    );
  }
}

