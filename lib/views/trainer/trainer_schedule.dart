import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/schedule/schedule_modal.dart';
import '../../components/coach/schedule/schedule_card.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TrainerScheduleView extends StatefulWidget {
  const TrainerScheduleView({super.key});

  @override
  State<TrainerScheduleView> createState() => _TrainerScheduleViewState();
}

class _TrainerScheduleViewState extends State<TrainerScheduleView> {
  DateTime _selectedDay = DateTime.now();
  final Map<DateTime, List<TimeSlot>> _schedule = {};

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    String format(TimeOfDay t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    return '${format(start)} - ${format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mi Horario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.neonBlue, size: 32),
                    onPressed: _addTimeSlot,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildTimeSlots(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    final timeSlots = _getAllTimeSlots();
    
    if (timeSlots.isEmpty) {
      return const Center(
        child: Text(
          'No hay horarios disponibles',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        return Slidable(
          key: ValueKey(slot),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => _toggleTimeSlot(slot),
                backgroundColor: Colors.transparent,
                icon: slot.isAvailable ? Icons.lock_open : Icons.lock,
                foregroundColor: slot.isAvailable ? AppColors.neonBlue : Colors.red,
              ),
              SlidableAction(
                onPressed: (_) => _deleteTimeSlot(slot.date, slot),
                backgroundColor: Colors.transparent,
                icon: Icons.delete,
                foregroundColor: Colors.red,
              ),
              SlidableAction(
                onPressed: (_) => _editTimeSlot(slot),
                backgroundColor: Colors.transparent,
                icon: Icons.edit,
                foregroundColor: AppColors.primaryBlue,
              ),
            ],
          ),
          child: ScheduleCard(
            dateString: "",  // Removing date string
            timeString: _formatTimeRange(slot.startTime, slot.endTime),
            sport: slot.sport,
            isAvailable: slot.isAvailable,
          ),
        );
      },
    );
  }

  // Get all time slots from all dates
  List<TimeSlot> _getAllTimeSlots() {
    List<TimeSlot> allSlots = [];
    _schedule.forEach((date, slots) {
      allSlots.addAll(slots);
    });
    return allSlots;
  }

  void _addTimeSlot() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddScheduleModal(),
    );

    if (result != null) {
      final from = result['from'] as String;
      final to = result['to'] as String;
      final sport = result['sport'] as String;
      final selectedDate = result['date'] as DateTime? ?? _selectedDay;
      
      // Parse time strings like '9:00 AM' to TimeOfDay
      TimeOfDay parseTime(String t) {
        final parts = t.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        if (parts.length > 1 && parts[1] == 'PM' && hour != 12) hour += 12;
        if (parts.length > 1 && parts[1] == 'AM' && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
      final startTime = parseTime(from);
      final endTime = parseTime(to);
      setState(() {
        // Use the selected date from the modal to store the time slot
        final dateKey = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        _schedule[dateKey] = [
          ...?_schedule[dateKey],
          TimeSlot(
            startTime: startTime,
            endTime: endTime,
            sport: sport,
            date: selectedDate,
          ),
        ];
      });
    }
  }

  void _toggleTimeSlot(TimeSlot slot) {
    setState(() {
      slot.isAvailable = !slot.isAvailable;
    });
  }

  void _deleteTimeSlot(DateTime day, TimeSlot slot) {
    setState(() {
      _schedule[day]?.remove(slot);
    });
  }

  void _editTimeSlot(TimeSlot slot) {
    // Implement edit logic or modal here
  }
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String sport;
  final DateTime date;
  bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.sport,
    required this.date,
    this.isAvailable = true,
  });
} 