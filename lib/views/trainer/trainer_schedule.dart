import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/schedule/schedule_modal.dart';
import '../../components/coach/schedule/schedule_card.dart';
import '../../services/schedule_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logger/logger.dart';
import '../../services/auth_service.dart';

final logger = Logger();
class TrainerScheduleView extends StatefulWidget {
  const TrainerScheduleView({super.key});

  @override
  State<TrainerScheduleView> createState() => _TrainerScheduleViewState();
}

class _TrainerScheduleViewState extends State<TrainerScheduleView> {
  final DateTime _selectedDay = DateTime.now();
  final Map<DateTime, List<TimeSlot>> _schedule = {};
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSchedule();
  }
  
  Future<void> _initializeSchedule() async {
    // Verify authentication before loading schedule
    final token = await _authService.getToken();
    if (token == null) {
      logger.e('Usuario no autenticado - no se puede cargar el horario');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Usuario no autenticado'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    
    logger.i('Usuario autenticado, cargando horario...');
    await _loadCoachSchedule();
  }

  Future<void> _loadCoachSchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      logger.i('Cargando disponibilidades del coach logueado...');
      final result = await _scheduleService.getOwnCoachAvailabilities();
      
      logger.i('Resultado de getCoachAvailabilities: ${result.toString()}');
      
      if (result['success']) {
        final data = result['data'];
        logger.i('Datos recibidos del servidor: $data');
        
        // Parse the response and populate _schedule
        if (data is List) {
          _schedule.clear();
          logger.i('Total de disponibilidades recibidas: ${data.length}');
          
          for (var item in data) {
            logger.d('Procesando item: $item');
            
            // Handle specific availability structure
            final dateStr = item['date'] as String?;
            final startTimeStr = item['start_time'] as String?;
            final endTimeStr = item['end_time'] as String?;
            final sportId = item['sport_id'] as int?;
            final location = item['location'] as String? ?? '';
            final isOnline = item['is_online'] as bool? ?? false;
            final isAvailable = true; // Default to available for specific availabilities
            
            // Log the coach_id to verify it's only the logged-in user's data
            final coachId = item['coach_id'];
            logger.i('Disponibilidad del coach ID: $coachId');
            
            // Map sport ID to sport name (you might need to enhance this)
            String sport = 'Fútbol'; // Default
            if (sportId != null) {
              // You can expand this mapping based on your sport IDs
              switch (sportId) {
                case 1:
                  sport = 'Fútbol';
                  break;
                default:
                  sport = 'Deporte ID $sportId';
              }
            }
            
            // Try to get sport name from the sport object if available
            if (item['sport'] != null && item['sport']['name_es'] != null) {
              sport = item['sport']['name_es'] as String;
            }
            
            
            if (dateStr != null && startTimeStr != null && endTimeStr != null) {
              try {
                // Parse date (format: "2025-06-15T00:00:00.000000Z")
                DateTime date;
                if (dateStr.contains('T')) {
                  // ISO format - use DateTime.parse
                  date = DateTime.parse(dateStr);
                } else {
                  // Simple format YYYY-MM-DD
                  final dateParts = dateStr.split('-');
                  if (dateParts.length == 3) {
                    date = DateTime(
                      int.parse(dateParts[0]),
                      int.parse(dateParts[1]),
                      int.parse(dateParts[2]),
                    );
                  } else {
                    logger.w('Formato de fecha inválido: $dateStr');
                    continue;
                  }
                }
                
                // Parse times (format: "09:00:00" or "09:00")
                final startTime = _parseTimeString(startTimeStr);
                final endTime = _parseTimeString(endTimeStr);
                
                if (startTime != null && endTime != null) {
                  final dateKey = DateTime(date.year, date.month, date.day);
                  
                  logger.d('Agregando disponibilidad: ${_formatDateString(date)} ${_formatTimeRange(startTime, endTime)} - $sport');
                  
                  _schedule[dateKey] = [
                    ...?_schedule[dateKey],
                    TimeSlot(
                      startTime: startTime,
                      endTime: endTime,
                      sport: sport,
                      date: date,
                      location: location,
                      isOnline: isOnline,
                      isAvailable: isAvailable,
                    ),
                  ];
                } else {
                  logger.w('Error parseando tiempos: start=$startTimeStr, end=$endTimeStr');
                }
              } catch (e) {
                logger.e('Error parseando horarios: start=$startTimeStr, end=$endTimeStr, error: $e');
              }
            } else {
                logger.w('Faltan datos en el item: fecha=$dateStr, inicio=$startTimeStr, fin=$endTimeStr');
            }
          }
          
          logger.i('Total de disponibilidades procesadas: ${_getAllTimeSlots().length}');
          setState(() {});
        } else {
          logger.w('Los datos recibidos no son una lista: $data');
        }
      } else {
        logger.e('Error del servidor: ${result['error']}');
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar horarios: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error inesperado al cargar disponibilidades: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      // Handle format like "14:30:00", "14:30", "09:00:00", or "09:00"
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        // Ignore seconds if present
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      logger.e('Error parsing time: $timeStr - $e');
    }
    return null;
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    String format(TimeOfDay t) => '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
    return '${format(start)} - ${format(end)}';
  }

  String _formatDateString(DateTime date) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    
    return '${date.day} de ${months[date.month]}';
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
                  Row(
                    children: [
                      if (!_isLoading)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.neonBlue, size: 28),
                          onPressed: _loadCoachSchedule,
                        ),
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: AppColors.neonBlue,
                              strokeWidth: 2,
                            )
                          : IconButton(
                              icon: const Icon(Icons.add, color: AppColors.neonBlue, size: 32),
                              onPressed: _addTimeSlot,
                            ),
                    ],
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
            dateString: _formatDateString(slot.date),
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
    if (_isLoading) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddScheduleModal(),
    );

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      final from = result['from'] as String;
      final to = result['to'] as String;
      final sport = result['sport'] as String;
      final selectedDate = result['date'] as DateTime? ?? _selectedDay;
      final isOnline = result['online'] as bool? ?? false;
      final location = result['ubicacion'] as String? ?? '';
      
      try {
        // Make API call to create availability
        final apiResult = await _scheduleService.createSpecificAvailability(
          sport: sport,
          date: selectedDate,
          startTime: from,
          endTime: to,
          isOnline: isOnline,
          location: location,
        );

        if (apiResult['success']) {
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
                location: location,
                isOnline: isOnline,
              ),
            ];
          });

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Disponibilidad creada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
          
          // Reload the schedule to get the updated list from the server
          _loadCoachSchedule();
        } else {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${apiResult['error'] ?? 'No se pudo crear la disponibilidad'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Handle any unexpected errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error inesperado: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
  final String location;
  final bool isOnline;
  bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.sport,
    required this.date,
    required this.location,
    required this.isOnline,
    this.isAvailable = true,
  });
} 