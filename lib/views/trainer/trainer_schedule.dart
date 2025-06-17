import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/schedule/schedule_modal.dart';
import '../../components/coach/schedule/schedule_card.dart';
import '../../services/schedule_service.dart';
import '../../services/profile_service.dart';
import '../../services/sports_service.dart';
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
  final ProfileService _profileService = ProfileService();
  final SportsService _sportsService = SportsService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  List<Sport> _coachSports = []; // Deportes del coach
  Map<int, String> _sportsMapping = {}; // Mapeo de ID a nombre de deporte

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
    
    logger.i('Usuario autenticado, cargando horario y deportes...');
    await Future.wait([
      _loadSportsMapping(),
      _loadCoachSports(),
    ]);
    
    // Load schedule after we have the sports mapping
    await _loadCoachSchedule();
  }

  Future<void> _loadSportsMapping() async {
    try {
      final result = await _sportsService.getAllSports();
      
      if (result['success']) {
        final data = result['data'];
        logger.i('Sports mapping data received: $data');
        
        if (data is List) {
          final newMapping = <int, String>{};
          for (var sport in data) {
            final id = sport['id'] as int?;
            final nameEs = sport['name_es'] as String?;
            final name = sport['name'] as String?;
            
            if (id != null) {
              // Prefer name_es, fallback to name
              final sportName = nameEs ?? name ?? 'Deporte ID $id';
              newMapping[id] = sportName;
              logger.d('Mapped sport: ID=$id -> Name=$sportName');
            }
          }
          
          if (mounted) {
            setState(() {
              _sportsMapping = newMapping;
            });
          }
          
          logger.i('Sports mapping loaded successfully: $_sportsMapping');
        } else {
          logger.w('Sports data is not a list: $data');
        }
      } else {
        logger.w('Error loading sports mapping: ${result['error']}');
      }
    } catch (e) {
      logger.e('Exception loading sports mapping: $e');
    }
  }

  Future<void> _loadCoachSports() async {
    try {
      logger.i('Cargando deportes del coach...');
      final result = await _profileService.getCoachProfileWithSports();
      
      if (result['success']) {
        final data = result['data'];
        logger.i('Coach profile with sports received: $data');
        
        if (mounted) {
          setState(() {
            if (data['sports'] != null && data['sports'] is List) {
              _coachSports = (data['sports'] as List)
                  .map((sportJson) {
                    // Handle the pivot structure from the coach response
                    if (sportJson['pivot'] != null) {
                      return Sport(
                        id: sportJson['pivot']['sport_id'],
                        sportId: sportJson['id'],
                        specificPrice: double.parse(sportJson['pivot']['specific_price'].toString()),
                        specificLocation: sportJson['pivot']['specific_location'] ?? '',
                        sessionDurationMinutes: sportJson['pivot']['session_duration_minutes'] ?? 60,
                      );
                    } else {
                      return Sport.fromJson(sportJson);
                    }
                  })
                  .toList();
            } else {
              _coachSports = [];
            }
          });
        }
        
        logger.i('Loaded ${_coachSports.length} coach sports');
      } else {
        logger.w('Error loading coach sports: ${result['error']}');
        if (mounted) {
          setState(() {
            _coachSports = [];
          });
        }
      }
    } catch (e) {
      logger.e('Exception loading coach sports: $e');
      if (mounted) {
        setState(() {
          _coachSports = [];
        });
      }
    }
  }

  Future<void> _loadCoachSchedule() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

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
            
            // Debug logging for sport resolution
            logger.d('Processing availability item: $item');
            logger.d('Sport ID from server: $sportId');
            logger.d('Available sports mapping: $_sportsMapping');
            logger.d('Sport object from server: ${item['sport']}');
            
            // Map sport ID to sport name using the loaded mapping
            String sport = 'Deporte Desconocido'; // Default fallback
            
            if (sportId != null) {
              // First try to get from our loaded mapping
              if (_sportsMapping.containsKey(sportId)) {
                sport = _sportsMapping[sportId]!;
                logger.d('Sport name from mapping: ID=$sportId -> Name=$sport');
              } else {
                sport = 'Deporte ID $sportId';
                logger.w('Sport ID $sportId not found in mapping, using fallback');
              }
            }
            
            // Try to get sport name from the sport object if available (this takes priority)
            if (item['sport'] != null) {
              final sportObj = item['sport'];
              if (sportObj['name_es'] != null) {
                sport = sportObj['name_es'] as String;
                logger.d('Sport name from server object: $sport');
              } else if (sportObj['name'] != null) {
                sport = sportObj['name'] as String;
                logger.d('Sport name from server object (name field): $sport');
              }
            }
            
            logger.i('Final sport resolved: ID=$sportId -> Name=$sport');
            
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
          if (mounted) {
            setState(() {});
          }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                          onPressed: () async {
                            await Future.wait([
                              _loadSportsMapping(),
                              _loadCoachSports(),
                            ]);
                            await _loadCoachSchedule();
                          },
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

    // Check if coach has sports
    if (_coachSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar deportes a tu perfil antes de crear disponibilidades.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddScheduleModal(coachSports: _coachSports),
    );

    if (result != null) {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

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
          
          if (mounted) {
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
          }

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
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _toggleTimeSlot(TimeSlot slot) {
    if (mounted) {
      setState(() {
        slot.isAvailable = !slot.isAvailable;
      });
    }
  }

  void _deleteTimeSlot(DateTime day, TimeSlot slot) {
    if (mounted) {
      setState(() {
        _schedule[day]?.remove(slot);
      });
    }
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