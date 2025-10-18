import 'package:flutter/material.dart';
import '/Pages/home_page.dart';
import '/Pages/trip_planner_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  // ✅ List of actual page widgets
  // Make sure each imported file (e.g., home_page.dart) contains a StatelessWidget
  // class HomePage extends StatelessWidget { ... }
  final List<Widget> _pages = const [
    HomePage(),
    TripPlannerPage(),
    //SearchPage(),
    //AccountPage(),
  ];

  // Function to handle tap on nav item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // update the current tab index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Display the selected page
      body: _pages[_selectedIndex],

      // Bottom navigation bar section
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Trip Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My profile',
          ),
        ],
      ),
    );
  }
}
