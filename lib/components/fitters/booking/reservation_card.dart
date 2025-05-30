import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../common/colors.dart';

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final Function(Map<String, dynamic>)? onEdit;
  final Function(Map<String, dynamic>)? onDelete;

  const ReservationCard({
    required this.reservation, 
    this.onEdit,
    this.onDelete,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final date = reservation['date'] as DateTime;
    return Slidable(
      key: ValueKey(reservation),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(reservation),
            backgroundColor: Colors.transparent,
            icon: Icons.edit,
            foregroundColor: AppColors.primaryBlue,
          ),
          SlidableAction(
            onPressed: (_) => onDelete?.call(reservation),
            backgroundColor: Colors.transparent,
            icon: Icons.delete,
            foregroundColor: Colors.red,
          ),
        ],
      ),
      child: SizedBox(
        width: 339,
        height: 79,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFA8C7FF).withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 79,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _monthName(date.month),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: Colors.white30,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        reservation['coach'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        reservation['sport'],
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        'Online: ${reservation['online'] ? 'sí' : 'no'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: Colors.white30,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      reservation['startTime'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      reservation['endTime'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return months[month];
  }
} 