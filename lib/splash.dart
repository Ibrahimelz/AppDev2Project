import 'package:appdev2/Employee/EmployeeHome.dart';
import 'package:appdev2/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Admin/AdminNotifications.dart';
import 'Employee/EmployeeNotifications.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key, this.openNotificationsPage = false});
  final bool openNotificationsPage;

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen>  with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 5), () async {
      if (widget.openNotificationsPage) {
        // Check user and role
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final email = user.email;
          final adminSnapshot = await FirebaseFirestore.instance.collection('Admins').where('email', isEqualTo: email).get();
          final isAdmin = adminSnapshot.docs.isNotEmpty;
          if (isAdmin) {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdminNotifications()));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => EmployeeNotifications(userEmail: email ?? '')));
          }
          return;
        }
        // If user is not logged in, just go to login screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
        return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/titanFitnessLogo.png"),
            SizedBox(height: 20),
            Text("Titan Fitness" , style: TextStyle(fontFamily: 'MyFont', color: Colors.black, fontSize: 32))
          ],
        ),
      ),
    );
  }
}
