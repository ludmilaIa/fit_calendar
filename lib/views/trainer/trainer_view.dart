import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../common/nav_bar.dart';

class TrainerView extends StatefulWidget {
  const TrainerView({super.key});

  @override
  State<TrainerView> createState() => _TrainerViewState();
}

class _TrainerViewState extends State<TrainerView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ReservationsScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: _screens[_currentIndex],
      bottomNavigationBar: TrainerNavBar(
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

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Calendario',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text(
          'Configuración',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
} 