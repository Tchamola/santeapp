import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Application Santé',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true, // Donne un look moderne et épuré
      ),

      home: HomeScreen(),
    );
  }
}
