import 'package:flutter/material.dart';
import '../common/colors.dart';
import '../common/nav_bar.dart';
import 'trainer/trainer_schedule.dart';
import 'trainer/coach_settings_screen.dart';
import '../components/coach/reservas/coach_reservation.dart';

class TrainerView extends StatefulWidget {
  const TrainerView({super.key});

  @override
  State<TrainerView> createState() => _TrainerViewState();
}

class _TrainerViewState extends State<TrainerView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CoachReservasView(),
    const TrainerScheduleView(),
    const CoachSettingsScreen(),
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