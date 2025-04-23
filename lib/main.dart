import 'package:appdev2/splash.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
   options: FirebaseOptions(
       apiKey: "AIzaSyCbyqHn4yXwCwUtayJdHuCRiM2SWiZ2Tyo",
       appId: "147369913623",
       messagingSenderId: "147369913623",
       projectId: "titanfitness-a55fd"
   )
  );
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     debugShowCheckedModeBanner: false,
     home: splashScreen(),
    );
  }
}
