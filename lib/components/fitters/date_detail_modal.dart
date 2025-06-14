import 'package:flutter/material.dart';
import '../../common/colors.dart';
import 'appointment_details_modal.dart';

String _formatTime(String timeStr) {
  try {
    // Convert from "09:00:00" to "9:00AM" format
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      
      String period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '${hour}:${minute.toString().padLeft(2, '0')}$period';
    }
  } catch (e) {
    // Return original if parsing fails
  }
  return timeStr;
}

class DateDetailModal extends StatefulWidget {
  final String date;
  final List<Map<String, dynamic>> availabilities;
  final String coachName;
  
  const DateDetailModal({
    required this.date,
    required this.availabilities,
    required this.coachName,
    Key? key,
  }) : super(key: key);

  @override
  State<DateDetailModal> createState() => _DateDetailModalState();
}

class _DateDetailModalState extends State<DateDetailModal> {
  int? selectedSlot;

  void _showAppointmentDetailsModal(BuildContext context, int index) {
    final availability = widget.availabilities[index];
    
    // Instead of closing the current modal, show the new one on top
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AppointmentDetailsModal(
        date: widget.date,
        timeStart: _formatTime(availability['start_time'] ?? '10:00:00'),
        timeEnd: _formatTime(availability['end_time'] ?? '11:00:00'),
        isOnline: availability['is_online'] ?? false,
        price: '\$${availability['price_per_person'] ?? '35'}',
        location: availability['location'] ?? 'Sin ubicación',
        availability: availability,
        coachName: widget.coachName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.softBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(32),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Horarios:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // Two-row horizontal scrollable grid for slots (both rows scroll together)
              Builder(
                builder: (context) {
                  final slots = widget.availabilities;
                  final half = (slots.length / 2).ceil();
                  final columns = half;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(columns, (colIdx) {
                        final firstIdx = colIdx;
                        final secondIdx = colIdx + half;
                        return Column(
                          children: [
                            if (firstIdx < slots.length)
                              _slotBox(
                                availability: slots[firstIdx],
                                index: firstIdx,
                                selectedSlot: selectedSlot,
                                onTap: (idx) {
                                  setState(() {
                                    selectedSlot = idx;
                                  });
                                  _showAppointmentDetailsModal(context, idx);
                                },
                              ),
                            const SizedBox(height: 16),
                            if (secondIdx < slots.length)
                              _slotBox(
                                availability: slots[secondIdx],
                                index: secondIdx,
                                selectedSlot: selectedSlot,
                                onTap: (idx) {
                                  setState(() {
                                    selectedSlot = idx;
                                  });
                                  _showAppointmentDetailsModal(context, idx);
                                },
                              ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _legendBox(AppColors.neonBlue),
                      const SizedBox(width: 8),
                      const Text('Seleccionado', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _legendBox(AppColors.exitRed),
                      const SizedBox(width: 8),
                      const Text('No disponible', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _legendBox(const Color(0xFFA8C7FF)),
                      const SizedBox(width: 8),
                      const Text('Disponible', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _legendBox(Color color) {
  return Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
  );
}

// Helper for slot box
Widget _slotBox({
  required Map<String, dynamic> availability,
  required int index,
  required int? selectedSlot,
  required Function(int) onTap,
}) {
  final isSelected = selectedSlot == index;
  final isAvailable = !(availability['is_booked'] ?? false) && 
                     availability['status'] == 'Available';
  final isOnline = availability['is_online'] == true;
  
  Color bgColor;
  if (isSelected) {
    bgColor = AppColors.neonBlue;
  } else if (!isAvailable) {
    bgColor = AppColors.exitRed;
  } else {
    bgColor = const Color(0xFFA8C7FF);
  }

  return Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: GestureDetector(
      onTap: isAvailable ? () => onTap(index) : null,
      child: Container(
        width: 140,
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(availability['start_time'] ?? '10:00:00'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatTime(availability['end_time'] ?? '11:00:00'),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            if (isOnline)
              const Icon(
                Icons.wifi,
                color: Colors.black,
                size: 16,
              ),
            Text(
              '\$${availability['price_per_person'] ?? '35'}',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
} 