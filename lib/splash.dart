import 'package:appdev2/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class splashScreen extends StatefulWidget {
  const splashScreen({super.key});

  @override
  State<splashScreen> createState() => _splashScreenState();
}

class _splashScreenState extends State<splashScreen>  with SingleTickerProviderStateMixin {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    Future.delayed(Duration( seconds: 5), () {
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
            Image(image: NetworkImage("https://github.com/user-attachments/assets/651528f6-3b78-41fb-8046-1b6242d7f3ea")),
            SizedBox(height: 20),
            Text("Titan Fitness" , style: TextStyle(fontFamily: 'MyFont', color: Colors.black, fontSize: 32))
          ],
        ),
      ),
    );
  }
}
