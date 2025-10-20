import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // Import your login page

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    InputDecoration buildInputDecoration(String hint, TextEditingController controller) {
      return InputDecoration(
        filled: true,
        fillColor: Colors.lightBlue.shade100,
        hintText: hint,
        suffixIcon: IconButton(
          icon: const Icon(Icons.cancel_outlined),
          onPressed: () => controller.clear(),
        ),
        border: const UnderlineInputBorder(),
      );
    }

    Future<void> registerUser() async {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final dob = dobController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      try {
        // Sign up with Supabase Auth
        final user = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (user != null && user.user != null) {
          // Insert user details into the 'users' table
          await Supabase.instance.client
              .from('users')
              .insert({
                'user_id': user.user!.id, // Link to auth user
                'first_name': firstName,
                'last_name': lastName,
                'dob': dob,
                'email': email,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

          // Show confirmation dialog
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Registration Successful'),
              content: const Text(
                  'Your account has been created.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to LoginPage
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Register',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 40),
            TextField(controller: firstNameController, decoration: buildInputDecoration('Enter First Name', firstNameController)),
            const SizedBox(height: 20),
            TextField(controller: lastNameController, decoration: buildInputDecoration('Enter Last Name', lastNameController)),
            const SizedBox(height: 20),
            TextField(controller: dobController, decoration: buildInputDecoration('Date of birth(YYYY/MM/DD)', dobController), keyboardType: TextInputType.datetime),
            const SizedBox(height: 20),
            TextField(controller: emailController, decoration: buildInputDecoration('Enter Email', emailController), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            TextField(controller: phoneController, decoration: buildInputDecoration('Enter Phone Number', phoneController), keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            TextField(controller: passwordController, obscureText: true, decoration: buildInputDecoration('Enter Password', passwordController)),
            const SizedBox(height: 20),
            TextField(controller: confirmPasswordController, obscureText: true, decoration: buildInputDecoration('Confirm Password', confirmPasswordController)),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Register', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
