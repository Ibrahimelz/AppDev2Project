import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({ required this.adminID ,super.key});

  final int adminID;

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String fname = '';
  String lname = '';
  String profilePicture = 'lebron.png';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Admins')
          .where('adminID', isEqualTo: widget.adminID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final adminData = querySnapshot.docs.first.data();
        setState(() {
          fname = adminData['fname'] ?? '';
          lname = adminData['lname'] ?? '';
          profilePicture = adminData['profilePicture'] ?? 'lebron.png';
        });
      }
    } catch (e) {
      print('Error loading admin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Titan Fitness", style: TextStyle(fontFamily: 'MyFont'),)),
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
              )
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_money),
              title: Text('Revenue'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel_outlined),
              title: Text('Cancelled Memberships'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 50,),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log out'),
              onTap: () {
                Navigator.pop(context);
              },
            )
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
                  fontFamily: 'MyFont'
                ),
              ),
              SizedBox(height: 50,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (){}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ), 
                    child: Text(
                      "Manage Employees", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.w500
                      ),
                    )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: (){}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ), 
                    child: Text(
                      "Register Employee", 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 20, 
                        fontWeight: FontWeight.w500
                      ),
                    )
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
