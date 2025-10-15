import 'package:flutter/material.dart';
import 'register_page.dart';
import '/components/NavBar.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/assets/logo.png', 
                height: 100,
              ),
              const SizedBox(height: 40),

              // Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightBlue.shade50,
                  hintText: 'Enter Password',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () => passwordController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.lightBlue.shade50,
                  hintText: 'Enter Email',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    onPressed: () => emailController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Forgot Password
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Forgot Password screen
                  },
                  child: const Text(
                    "Forgot password ?",
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Register Button
                  ElevatedButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Register',style:TextStyle(color :Colors.white),),
                    ),
                  ),

                  // Log-In Button
                  ElevatedButton(
                    onPressed: () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BottomNav()),
                      );
                      // Handle Log-In
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Log-In',style:TextStyle(color :Colors.white),),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
