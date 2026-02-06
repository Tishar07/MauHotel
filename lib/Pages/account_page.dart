import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../accessibility/accessibility_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final supabase = Supabase.instance.client;

  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('users')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data != null) {
      setState(() {
        _emailController.text = data['email'] ?? '';
        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _phoneController.text = data['phone_number'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    final user = supabase.auth.currentUser;

    try {
      await supabase
          .from('users')
          .update({
            'email': _emailController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'dob': _dobController.text,
            'phone_number': _phoneController.text,
          })
          .eq('user_id', user!.id);

      if (_passwordController.text.isNotEmpty) {
        await supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AccessibilityState.t(
              'Profile updated successfully!',
              'Profil mis à jour avec succès !',
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AccessibilityState.t('Error: $e', 'Erreur : $e')),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboardType,
    bool highContrast = false, // NEW
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: highContrast ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: highContrast ? Colors.white70 : Colors.black54,
          ),
          filled: highContrast,
          fillColor: highContrast ? Colors.grey[900] : null,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: highContrast ? Colors.white70 : null,
                  ),
                  onPressed: () => setState(() => controller.clear()),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.accentBlue, width: 1.2),
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AccessibilityState.rebuild,
      builder: (context, _) {
        final highContrast = AccessibilityState.contrast.value >= 2;

        return Scaffold(
          backgroundColor: highContrast ? Colors.black : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: highContrast
                        ? Colors.grey[800]
                        : Colors.blueGrey.shade100,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: highContrast ? Colors.white70 : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AccessibilityState.t(
                        'Edit Profile',
                        'Modifier le profil',
                      ),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: highContrast ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    'Email',
                    _emailController,
                    keyboardType: TextInputType.emailAddress,
                    highContrast: highContrast,
                  ),
                  _buildTextField(
                    'First Name',
                    _firstNameController,
                    highContrast: highContrast,
                  ),
                  _buildTextField(
                    'Last Name',
                    _lastNameController,
                    highContrast: highContrast,
                  ),
                  _buildTextField(
                    'Date Of Birth',
                    _dobController,
                    highContrast: highContrast,
                  ),
                  _buildTextField(
                    'Phone Number',
                    _phoneController,
                    keyboardType: TextInputType.phone,
                    highContrast: highContrast,
                  ),
                  _buildTextField(
                    'Password',
                    _passwordController,
                    obscure: true,
                    highContrast: highContrast,
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AccessibilityState.t('Save', 'Enregistrer'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
