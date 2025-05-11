import 'package:flutter/material.dart';
import '../common/colors.dart';
import '../common/nav_bar.dart';
import 'fitters/settings_screen.dart';
import 'fitters/reservations_screen.dart';

class FitterView extends StatefulWidget {
  const FitterView({super.key});

  @override
  State<FitterView> createState() => _FitterViewState();
}

class _FitterViewState extends State<FitterView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FitterReservationsScreen(),
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