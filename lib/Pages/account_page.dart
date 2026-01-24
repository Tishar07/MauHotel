import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

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

  // ⭐ NEW — for Add Review Section
  final _commentController = TextEditingController();
  String? _selectedHotel;
  List<Map<String, dynamic>> _hotels = [];
  double _rating = 0; // ⭐ current rating (1–5)

  bool _loading = false;
  bool _submittingReview = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadHotels(); // Load hotels for dropdown
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

  Future<void> _loadHotels() async {
    try {
      final data = await supabase.from('hotels').select('hotel_id, name');
      setState(() {
        _hotels = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load hotels: $e')));
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
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  // ⭐ NEW — Add review logic (now includes rating)
  Future<void> _addReview() async {
    if (_selectedHotel == null ||
        _commentController.text.trim().isEmpty ||
        _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a hotel, give a rating, and write a comment',
          ),
        ),
      );
      return;
    }

    setState(() => _submittingReview = true);
    final user = supabase.auth.currentUser;

    try {
      final selected = _hotels.firstWhere((h) => h['name'] == _selectedHotel);
      final hotelId = selected['hotel_id'];

      await supabase.from('reviews').insert({
        'hotel_id': hotelId,
        'comment': _commentController.text.trim(),
        'rating': _rating, // ⭐ Added rating
        'review_date': DateTime.now().toIso8601String(),
        'user_id': user!.id,
      });

      _commentController.clear();
      setState(() {
        _selectedHotel = null;
        _rating = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add review: $e')));
    } finally {
      setState(() => _submittingReview = false);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => controller.clear()),
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: AppTheme.accentBlue,
              width: 1.2,
            ),
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

  // ⭐ NEW — Widget to display 5 stars for rating
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return IconButton(
          icon: Icon(
            Icons.star,
            color: _rating >= starIndex ? Colors.amber : Colors.grey[300],
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _rating = starIndex.toDouble();
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueGrey.shade100,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                'Email',
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField('First Name', _firstNameController),
              _buildTextField('Last Name', _lastNameController),
              _buildTextField('Date Of Birth', _dobController),
              _buildTextField(
                'Phone Number',
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField('Password', _passwordController, obscure: true),
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
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // ⭐ NEW — Add Review Section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add a Review',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedHotel,
                items: _hotels
                    .map(
                      (hotel) => DropdownMenuItem<String>(
                        value: hotel['name'],
                        child: Text(hotel['name']),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedHotel = value),
                decoration: InputDecoration(
                  labelText: 'Select Hotel',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Text('Your Rating:', style: TextStyle(fontSize: 16)),
              _buildStarRating(), // ⭐ Rating stars
              const SizedBox(height: 8),

              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Your Comment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submittingReview ? null : _addReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _submittingReview
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(
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
  }
}
