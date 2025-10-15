import 'package:flutter/material.dart';
//import 'package:supabase_flutter/supabase_flutter.dart';
import 'Pages/login_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Hotel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(), 
    );
  }
}
