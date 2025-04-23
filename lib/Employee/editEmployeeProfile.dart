import 'package:flutter/material.dart';

class editEmployeeProfile extends StatefulWidget {
  const editEmployeeProfile({super.key});

  @override
  State<editEmployeeProfile> createState() => _editEmployeeProfileState();
}

class _editEmployeeProfileState extends State<editEmployeeProfile> {

  final TextEditingController addressController = TextEditingController(text: "1234 Street");
  final TextEditingController emailController = TextEditingController(text: "johndoe@gmail.com");
  final TextEditingController phoneController = TextEditingController(text: "+14987889999");
  final TextEditingController passwordController = TextEditingController(text: "*************");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}

