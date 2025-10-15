import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers for each field
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController dobController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    // Common Input Decoration
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

            TextField(
              controller: firstNameController,
              decoration: buildInputDecoration('Enter First Name', firstNameController),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: lastNameController,
              decoration: buildInputDecoration('Enter Last Name', lastNameController),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: dobController,
              decoration: buildInputDecoration('Date of birth(YYYY/MM/DD)', dobController),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: emailController,
              decoration: buildInputDecoration('Enter Email', emailController),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              decoration: buildInputDecoration('Enter Phone Number', phoneController),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: buildInputDecoration('Enter Password', passwordController),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: buildInputDecoration('Confirm Password', confirmPasswordController),
            ),
            const SizedBox(height: 40),

            // Register Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle registration logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text(
                  'Register',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
