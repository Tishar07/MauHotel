import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: const [
            ListTile(title: Text('Name: Pushkaar')),
            ListTile(title: Text('Email: pushkaar@example.com')),
            ListTile(title: Text('Phone: +230 57777777')),
          ],
        ),
      ),
    );
  }
}
