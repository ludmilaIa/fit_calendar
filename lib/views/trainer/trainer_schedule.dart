import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeSlot>> _schedule = {};

  String _formatDate(DateTime date) {
    // Example: 10 de Abril
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month]}';
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    String format(TimeOfDay t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    return '${format(start)} - ${format(end)}';
  }

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
    final dateString = _formatDate(_selectedDay!);
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
                onPressed: (_) => _deleteTimeSlot(_selectedDay!, slot),
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
            dateString: dateString,
            timeString: _formatTimeRange(slot.startTime, slot.endTime),
            sport: slot.sport,
            isAvailable: slot.isAvailable,
          ),
        );
      },
    );
  }

  void _addTimeSlot() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un día primero'),
          backgroundColor: AppColors.neonBlue,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddScheduleModal(),
    );

    if (result != null) {
      final from = result['from'] as String;
      final to = result['to'] as String;
      final sport = result['sport'] as String;
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
        _schedule[_selectedDay!] = [
          ...?_schedule[_selectedDay!],
          TimeSlot(
            startTime: startTime,
            endTime: endTime,
            sport: sport,
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
  bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.sport,
    this.isAvailable = true,
  });
} 