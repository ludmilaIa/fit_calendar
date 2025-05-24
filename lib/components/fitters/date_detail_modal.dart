import 'package:flutter/material.dart';
import '../../common/colors.dart';
import 'appointment_details_modal.dart';

class DateDetailModal extends StatefulWidget {
  final String date;
  const DateDetailModal({required this.date});

  @override
  State<DateDetailModal> createState() => _DateDetailModalState();
}

class _DateDetailModalState extends State<DateDetailModal> {
  int? selectedSlot;

  // Example slot data
  final List<Map<String, dynamic>> slots = [
    {'time1': '10:00AM', 'time2': '11:00AM', 'online': true, 'available': true, 'price': '\$6', 'location': 'La Rosaleda'},
    {'time1': '10:00AM', 'time2': '11:00AM', 'online': false, 'available': false, 'price': '\$6', 'location': 'La Rosaleda'},
    {'time1': '10:00AM', 'time2': '11:00AM', 'online': true, 'available': true, 'price': '\$6', 'location': 'La Rosaleda'},
    {'time1': '10:00AM', 'time2': '11:00AM', 'online': true, 'available': true, 'price': '\$6', 'location': 'La Rosaleda'},
    {'time1': '10:00AM', 'time2': '11:00AM', 'online': false, 'available': false, 'price': '\$6', 'location': 'La Rosaleda'},
    {'time1': '10:00AM', 'time2': '11:00AM', 'online': false, 'available': true, 'price': '\$6', 'location': 'La Rosaleda'},
  ];

  void _showAppointmentDetailsModal(BuildContext context, int index) {
    final slot = slots[index];
    
    // Instead of closing the current modal, show the new one on top
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AppointmentDetailsModal(
        date: widget.date,
        timeStart: slot['time1'] ?? '10:00AM', 
        timeEnd: slot['time2'] ?? '11:00AM',
        isOnline: slot['online'] ?? false,
        price: slot['price'] ?? '\$6',
        location: slot['location'] ?? 'La Rosaleda',
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
                                slot: slots[firstIdx],
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
                                slot: slots[secondIdx],
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
  required Map<String, dynamic> slot,
  required int index,
  required int? selectedSlot,
  required Function(int) onTap,
}) {
  final isSelected = selectedSlot == index;
  final isAvailable = slot['available'] == true;
  final isOnline = slot['online'] == true;
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
        width: 128,
        height: 90,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                slot['time1'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                slot['time2'],
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Online: ${isOnline ? 'si' : 'No'}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
} 