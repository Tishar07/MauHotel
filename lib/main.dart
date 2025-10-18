import 'package:flutter/material.dart';
import 'Pages/login_page.dart';
import 'Pages/search_page.dart';
import 'Pages/hotel_page.dart';
import 'Pages/account_page.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/search': (context) => const SearchPage(),
        '/hotel': (context) => const HotelPage(),
        '/account': (context) => const AccountPage(),
      },
    );
  }
}
