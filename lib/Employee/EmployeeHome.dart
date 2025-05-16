import 'package:appdev2/Employee/EmployeeTutorial.dart';
import 'package:appdev2/Employee/editEmployeeProfile.dart';
import 'package:appdev2/Employee/manageClients.dart';
import 'package:appdev2/Employee/registerClient.dart';
import 'package:appdev2/login.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appdev2/Employee/EmployeeNotifications.dart';
import 'package:appdev2/Employee/branch.dart';
import 'package:appdev2/Employee/groupChat.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(myApp());
}

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: employeeHome(employeeID: 1),
    );
  }
}

class employeeHome extends StatefulWidget {
  const employeeHome({required this.employeeID, super.key});

  final int employeeID;

  @override
  State<employeeHome> createState() => _employeeHomeState();
}

class _employeeHomeState extends State<employeeHome> {
  String fname = '';
  String lname = '';
  String profilePicture = 'lebron.png';
  String email = '';
  String quote = "Loading inspirational quote...";

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
    fetchQuote();
  }

  Future<void> _loadEmployeeData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Employees')
          .where('employeeID', isEqualTo: widget.employeeID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final employeeData = querySnapshot.docs.first.data();
        setState(() {
          fname = employeeData['fname'] ?? '';
          lname = employeeData['lname'] ?? '';
          profilePicture = employeeData['profilePicture'] ?? 'lebron.png';
          email = employeeData['email'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading employee data: $e');
    }
  }

  Future<void> fetchQuote() async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          quote = '${data[0]['q']} - ${data[0]['a']}';
        });
      } else {
        setState(() {
          quote = 'Failed to load quote.';
        });
      }
    } catch (e) {
      setState(() {
        quote = 'Error fetching quote.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Titan Fitness", style: TextStyle(fontFamily: 'MyFont')),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orangeAccent),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: AssetImage("assets/images/$profilePicture"),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$fname $lname',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeNotifications(userEmail: email)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_2_outlined),
              title: Text('Edit Profile'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => editEmployeeProfile(employeeID: widget.employeeID)));
              },
            ),
            ListTile(
              leading: Icon(Icons.my_location),
              title: Text('Branch'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const MapScreen(locationTitle: 'TitanFitness branch location'),
                ));
              },
            ),
            // ListTile(
            //   leading: Icon(Icons.message),
            //   title: Text('Group chat'),
            //   onTap: () {
            //     Navigator.of(context).push(MaterialPageRoute(
            //       builder: (context) => GroupChat(
            //         employeeID: widget.employeeID.toString(),
            //         name: '$fname $lname',
            //       ),
            //     ));
            //   },
            // ),
            SizedBox(height: 50),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "Hello,\n$fname $lname",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontFamily: 'MyFont',
                ),
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Employeetutorial()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Tutorial",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ManageClients()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Manage Clients",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterClientPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Register Clients",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  quote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA25B), // soft orange, similar to the image
                    fontFamily: 'MyFont',   // optional: can customize with a better matching font
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
