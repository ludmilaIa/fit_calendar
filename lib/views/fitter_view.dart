import 'package:flutter/material.dart';
import '../common/colors.dart';
import '../common/nav_bar.dart';
import 'fitters/settings_screen.dart';

class FitterView extends StatefulWidget {
  const FitterView({super.key});

  @override
  State<FitterView> createState() => _FitterViewState();
}

class _FitterViewState extends State<FitterView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ReservationsScreen(),
    const ExploreScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: _screens[_currentIndex],
      bottomNavigationBar: FitterNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Placeholder screens - You can move these to separate files later
class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Reservas',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Explorar',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 