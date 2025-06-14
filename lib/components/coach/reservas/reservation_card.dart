import 'package:flutter/material.dart';

class ReservationCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const ReservationCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = _parseDate(booking['date'] ?? booking['specific_availability']?['date']);
    final startTime = booking['specific_availability']?['start_time'] ?? '10:00';
    final endTime = booking['specific_availability']?['end_time'] ?? '11:00';
    final studentName = booking['student']?['name'] ?? booking['user']?['name'] ?? 'Usuario';
    final sportName = booking['specific_availability']?['sport']?['name_es'] ?? 
                     booking['sport']?['name_es'] ?? 'Deporte';
    final isOnline = booking['specific_availability']?['is_online'] ?? false;

    return Container(
      width: 339,
      height: 79,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFA8C7FF).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Date
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              color: Colors.transparent,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dateTime?.day.toString() ?? '11',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getMonthName(dateTime?.month ?? 4),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // First vertical divider
          Container(
            width: 1.5,
            height: 55,
            color: Colors.white30,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    sportName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Online: ${isOnline ? 'sí' : 'no'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Second vertical divider
          Container(
            width: 1.5,
            height: 55,
            color: Colors.white30,
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          // Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(startTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTime(endTime),
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
    );
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    try {
      // Handle different date formats
      if (dateStr.contains('T')) {
        // ISO format: "2025-06-15T00:00:00.000000Z"
        return DateTime.parse(dateStr);
      } else {
        // Simple format: "2025-06-15"
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }

  String _getMonthName(int month) {
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

  String _formatTime(String timeStr) {
    try {
      // Convert "14:30:00" or "14:30" to "2:30 PM"
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        
        String period = 'AM';
        if (hour >= 12) {
          period = 'PM';
          if (hour > 12) hour -= 12;
        }
        if (hour == 0) hour = 12;
        
        return '${hour}:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // Return original string if formatting fails
    }
    return timeStr;
  }
} 