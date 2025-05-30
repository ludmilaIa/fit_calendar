import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/reservas/reservation_card.dart';

class CoachReservasView extends StatelessWidget {
  const CoachReservasView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Reservas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Dropdown Mes
              Container(
                width: 353,
                height: 51,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Seleccionar mes',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white70),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Dropdown Tipo
              Container(
                width: 353,
                height: 51,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Seleccionar tipo',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white70),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Use the new ReservationCard widget
              const ReservationCard(),
            ],
          ),
        ),
      ),
    );
  }
} 