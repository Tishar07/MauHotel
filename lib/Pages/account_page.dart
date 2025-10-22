import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
        userProfile = null;
      });
      return;
    }

    try {
      final response = await supabase
          .from('profiles') // Make sure this table exists
          .select()
          .eq('id', user.id)
          .single();

      setState(() {
        userProfile = response;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching profile: $e");
      setState(() {
        userProfile = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Account')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile == null
          ? const Center(child: Text("No user profile found."))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text('Name: ${userProfile!['name'] ?? 'N/A'}'),
                  ),
                  ListTile(
                    title: Text('Email: ${userProfile!['email'] ?? 'N/A'}'),
                  ),
                  ListTile(
                    title: Text('Phone: ${userProfile!['phone'] ?? 'N/A'}'),
                  ),
                ],
              ),
            ),
    );
  }
}
