import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/schedule/schedule_modal.dart';
import '../../components/coach/schedule/schedule_card.dart';
import '../../services/schedule_service.dart';
import '../../services/profile_service.dart';
import '../../services/sports_service.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../services/auth_service.dart';
import 'dart:developer' as developer;

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
            }
          }
          
          if (mounted) {
            setState(() {
              _sportsMapping = newMapping;
            });
          }
        }
      }
    } catch (e) {
      // Keep only critical error logging
    }
  }

  Future<void> _loadCoachSports() async {
    try {
      final result = await _profileService.getCoachProfileWithSports();
      
      if (result['success']) {
        final data = result['data'];
        
        if (mounted) {
          setState(() {
            if (data['sports'] != null && data['sports'] is List) {
              final serverSports = (data['sports'] as List)
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
              
              // Solo sobrescribir la lista de deportes si:
              // 1. No tenemos deportes actualmente, O
              // 2. El servidor devuelve más deportes de los que tenemos
              if (_coachSports.isEmpty || serverSports.length > _coachSports.length) {
                _coachSports = serverSports;
              } else {
                // Si el servidor devuelve menos deportes, puede ser un bug del backend
                // Mantenemos la lista actual y logeamos el problema
                developer.log('Servidor devuelve ${serverSports.length} deportes en schedule, pero tenemos ${_coachSports.length}. Manteniendo lista actual.');
              }
            } else {
              // Solo limpiar la lista si realmente no hay deportes Y no tenemos ninguno
              if (_coachSports.isEmpty) {
                _coachSports = [];
              }
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            // Solo limpiar si no tenemos deportes cargados
            if (_coachSports.isEmpty) {
              _coachSports = [];
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Solo limpiar si no tenemos deportes cargados
          if (_coachSports.isEmpty) {
            _coachSports = [];
          }
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
      final result = await _scheduleService.getOwnCoachAvailabilities();
      
      if (result['success']) {
        final data = result['data'];
        
        // Parse the response and populate _schedule
        if (data is List) {
          _schedule.clear();
          
          for (var item in data) {            
            // Handle specific availability structure
            final dateStr = item['date'] as String?;
            final startTimeStr = item['start_time'] as String?;
            final endTimeStr = item['end_time'] as String?;
            final sportId = item['sport_id'] as int?;
            final location = item['location'] as String? ?? '';
            final isOnline = item['is_online'] as bool? ?? false;
            final isAvailable = true; // Default to available for specific availabilities
            final availabilityId = item['id'] as int?; // Capturar el ID de la disponibilidad específica
            
            // Map sport ID to sport name using the loaded mapping
            String sport = 'Deporte Desconocido'; // Default fallback
            
            if (sportId != null) {
              // First try to get from our loaded mapping
              if (_sportsMapping.containsKey(sportId)) {
                sport = _sportsMapping[sportId]!;
              } else {
                sport = 'Deporte ID $sportId';
              }
            }
            
            // Try to get sport name from the sport object if available (this takes priority)
            if (item['sport'] != null) {
              final sportObj = item['sport'];
              if (sportObj['name_es'] != null) {
                sport = sportObj['name_es'] as String;
              } else if (sportObj['name'] != null) {
                sport = sportObj['name'] as String;
              }
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
                    continue;
                  }
                }
                
                // Parse times (format: "09:00:00" or "09:00")
                final startTime = _parseTimeString(startTimeStr);
                final endTime = _parseTimeString(endTimeStr);
                
                if (startTime != null && endTime != null) {
                  final dateKey = DateTime(date.year, date.month, date.day);
                  
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
                      availabilityId: availabilityId,
                    ),
                  ];
                }
              } catch (e) {
                // Continue processing other items if one fails
              }
            }
          }
          
          if (mounted) {
            setState(() {});
          }
        }
      } else {
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
      // Ignore parsing errors and return null
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
                  // availabilityId será null para slots creados localmente hasta que se recargue
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

  void _deleteTimeSlot(DateTime day, TimeSlot slot) async {
    // Mostrar confirmación antes de eliminar
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkGray,
          title: const Text(
            '¿Eliminar disponibilidad?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Se eliminará la disponibilidad del ${_formatDateString(slot.date)} de ${_formatTimeRange(slot.startTime, slot.endTime)} para ${slot.sport}',
            style: TextStyle(color: AppColors.gray),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.gray.withAlpha(51),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(153),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Si tiene availabilityId, eliminar del servidor
      if (slot.availabilityId != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          final result = await _scheduleService.deleteSpecificAvailability(slot.availabilityId!);
          
          if (result['success']) {
            // Eliminar del estado local
            if (mounted) {
              setState(() {
                _schedule[day]?.remove(slot);
                _isLoading = false;
              });
            }

            // Mostrar mensaje de éxito
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disponibilidad eliminada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            // Recargar para sincronizar con el servidor
            _loadCoachSchedule();
          } else {
            setState(() {
              _isLoading = false;
            });

            // Mostrar mensaje de error
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${result['error'] ?? 'No se pudo eliminar la disponibilidad'}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } catch (e) {
          setState(() {
            _isLoading = false;
          });

          // Mostrar mensaje de error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error inesperado: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Si no tiene availabilityId, solo eliminar localmente (slot creado pero no guardado)
        if (mounted) {
          setState(() {
            _schedule[day]?.remove(slot);
          });
        }
      }
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
  final int? availabilityId; // ID de la disponibilidad específica del servidor
  bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.sport,
    required this.date,
    required this.location,
    required this.isOnline,
    this.availabilityId,
    this.isAvailable = true,
  });
} 