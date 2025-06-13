import 'package:flutter/material.dart';
import '../../../common/colors.dart';

class ScheduleCard extends StatelessWidget {
  final String dateString; // e.g. '15 de Junio'
  final String timeString; // e.g. '9:00 - 10:00'
  final String sport;
  final bool isAvailable;

  const ScheduleCard({
    super.key,
    required this.dateString,
    required this.timeString,
    required this.sport,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 397,
      height: 66,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$dateString $timeString',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                sport,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isAvailable ? 'Disponible' : 'Ocupado',
            style: TextStyle(
              color: isAvailable ? AppColors.neonBlue : Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 