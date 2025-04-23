import 'package:appdev2/EmployeeTutorial.dart';
import 'package:flutter/material.dart';

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
  const employeeHome({ required this.employeeID ,super.key});

  final int employeeID;

  @override
  State<employeeHome> createState() => _employeeHomeState();
}

class _employeeHomeState extends State<employeeHome> {
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
                    backgroundImage: AssetImage("assets/images/lebron.png"),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lebron James',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person_2_outlined),
              title: Text('Edit Profile'),
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
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 30), child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text("Hello,\n Lebron James" , style: TextStyle(color: Colors.black, fontSize: 40, fontFamily: 'MyFont'),),
            SizedBox(height: 50,),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(onPressed: (){

                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => Employeetutorial()));

                }, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    )
                ), child: Text("Tutorial", style: TextStyle( color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),)),
              ),),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    )
                ), child: Text("Manage Clients", style: TextStyle( color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),)),
              ),),
            Padding(padding: const EdgeInsets.symmetric(vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(onPressed: (){}, style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    )
                ), child: Text("Register Clients", style: TextStyle( color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),)),
              ),)
          ],
        ),
        )
      ),
    );
  }
}
