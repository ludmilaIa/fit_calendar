import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../common/colors.dart';
import '../../components/schedule_modal.dart';

class TrainerScheduleView extends StatefulWidget {
  const TrainerScheduleView({super.key});

  @override
  State<TrainerScheduleView> createState() => _TrainerScheduleViewState();
}

class _TrainerScheduleViewState extends State<TrainerScheduleView> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeSlot>> _schedule = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      appBar: AppBar(
        backgroundColor: AppColors.softBlack,
        title: const Text(
          'Mi Horario',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonBlue),
            onPressed: _addTimeSlot,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return _selectedDay != null && isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.neonBlue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.black),
              todayDecoration: const BoxDecoration(),
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white),
              disabledTextStyle: const TextStyle(color: Colors.grey),
              disabledDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            enabledDayPredicate: (day) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              return day.isAfter(today.subtract(const Duration(days: 1)));
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: AppColors.neonBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.black),
              titleTextStyle: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _buildTimeSlots(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_selectedDay == null) {
      return const Center(
        child: Text(
          'Selecciona un día para ver los horarios',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final timeSlots = _schedule[_selectedDay] ?? [];
    
    return ListView.builder(
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        return ListTile(
          title: Text(
            '${slot.startTime.hour}:${slot.startTime.minute.toString().padLeft(2, '0')} - '
            '${slot.endTime.hour}:${slot.endTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            slot.isAvailable ? 'Disponible' : 'Ocupado',
            style: TextStyle(
              color: slot.isAvailable ? AppColors.neonBlue : Colors.red,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              slot.isAvailable ? Icons.lock : Icons.lock_open,
              color: slot.isAvailable ? Colors.red : AppColors.neonBlue,
            ),
            onPressed: () => _toggleTimeSlot(slot),
          ),
        );
      },
    );
  }

  void _addTimeSlot() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un día primero'),
          backgroundColor: AppColors.neonBlue,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const AddScheduleModal(),
    );
  }

  void _toggleTimeSlot(TimeSlot slot) {
    setState(() {
      slot.isAvailable = !slot.isAvailable;
    });
  }
}

class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });
} 