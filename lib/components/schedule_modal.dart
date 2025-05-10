import 'package:flutter/material.dart';
import '../common/colors.dart';

class AddScheduleModal extends StatefulWidget {
  const AddScheduleModal({super.key});

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  String selectedSport = 'Futbol';
  int selectedFrom = 0;
  int selectedTo = 0;
  int selectedOnline = 0; // 0: Si, 1: No

  final List<String> times = [
    '8:00 AM', '8:30 AM', '9:00 AM'
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.softBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Deporte', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: const Text('Futbol', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              const Text('Desde', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(times.length, (i) => _timeButton(i, true)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Hasta', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(times.length, (i) => _timeButton(i, false)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Online', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _onlineButton(0, 'Si'),
                  const SizedBox(width: 8),
                  _onlineButton(1, 'No'),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 140,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop({
                          'sport': selectedSport,
                          'from': times[selectedFrom],
                          'to': times[selectedTo],
                          'online': selectedOnline == 0,
                        });
                      },
                      child: const Text('Agregar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeButton(int i, bool isFrom) {
    bool isSelected = isFrom ? selectedFrom == i : selectedTo == i;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isFrom) {
              selectedFrom = i;
            } else {
              selectedTo = i;
            }
          });
        },
        child: SizedBox(
          width: 100,
          height: 43,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.neonBlue.withOpacity(0.6) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: Text(
              times[i],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _onlineButton(int value, String label) {
    bool isSelected = selectedOnline == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOnline = value;
        });
      },
      child: SizedBox(
        width: 40,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonBlue.withOpacity(0.6) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
} 