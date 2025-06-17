import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../components/fitters/booking/reservation_card.dart';
import '../../services/booking_service.dart';
import '../../common/colors.dart';

class FitterReservationsScreen extends StatefulWidget {
  const FitterReservationsScreen({super.key});

  @override
  State<FitterReservationsScreen> createState() => _FitterReservationsScreenState();
}

class _FitterReservationsScreenState extends State<FitterReservationsScreen> {
  final BookingService _bookingService = BookingService();
  
  String? selectedSport;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  Set<String> _sports = {};

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  String _getSportNameFromId(dynamic sportId) {
    // Convert common sport IDs to names
    final sportMap = {
      1: 'Fútbol',
      2: 'Baloncesto', 
      3: 'Tenis',
      4: 'Natación',
      5: 'Voleibol',
      6: 'Gimnasia',
      7: 'Boxeo',
      8: 'Atletismo',
      9: 'Ciclismo',
      10: 'Yoga'
    };
    
    int? id;
    if (sportId is int) {
      id = sportId;
    } else if (sportId is String) {
      id = int.tryParse(sportId);
    }
    
    return sportMap[id] ?? 'Deporte $sportId';
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _bookingService.getBookings();
      
      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        
        setState(() {
          _bookings = data.map((item) => Map<String, dynamic>.from(item)).toList();
          
          // Extract unique sports using the proper mapping
          _sports.clear();
          
          for (var booking in _bookings) {
            final sportId = booking['specific_availability']?['sport_id'];
            if (sportId != null) {
              final sportName = _getSportNameFromId(sportId);
              _sports.add(sportName);
            }
          }
        });
        
        developer.log('Reservas cargadas: ${_bookings.length}');
        developer.log('Deportes encontrados: $_sports');
        
        // Log booking statuses for debugging
        for (var booking in _bookings) {
          developer.log('Reserva ID: ${booking['id']}, Status: ${booking['status']}, cancelled_at: ${booking['cancelled_at']}');
        }
        
        String firstCoachName = 'N/A';
        if (_bookings.isNotEmpty) {
          firstCoachName = _bookings[0]['coach']?['user']?['name'] ?? 'N/A';
        }
        developer.log('Primera reserva coach: $firstCoachName');
      } else {
        developer.log('Error al cargar reservas: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar reservas: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Error inesperado: $e');
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

  Future<void> _cancelBooking(Map<String, dynamic> reservationData) async {
    String? selectedReason;
    final List<String> cancelReasons = [
      'No puedo asistir',
      'Cambio de planes',
      'Problema de horario',
      'Motivos personales',
      'Otros'
    ];

    // Show confirmation dialog with reason selection
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF4B4949),
              title: const Text(
                'Cancelar Reserva',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¿Estás seguro de que quieres cancelar esta reserva?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Motivo de cancelación:',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF6B6B6B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    dropdownColor: const Color(0xFF6B6B6B),
                    style: const TextStyle(color: Colors.white),
                    hint: const Text(
                      'Selecciona un motivo',
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: cancelReasons.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'No',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                TextButton(
                  onPressed: selectedReason != null 
                    ? () => Navigator.of(context).pop(true)
                    : null,
                  child: Text(
                    'Sí, cancelar',
                    style: TextStyle(
                      color: selectedReason != null ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || selectedReason == null) return;

    try {
      // Get booking ID from original booking data
      final originalBooking = reservationData['originalBooking'];
      final bookingId = originalBooking?['id'];
      
      if (bookingId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se pudo obtener el ID de la reserva'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      developer.log('Intentando cancelar reserva con ID: $bookingId, motivo: $selectedReason');

      final result = await _bookingService.cancelBooking(bookingId, cancelledReason: selectedReason);
      
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload bookings to refresh the list
        await _loadBookings();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cancelar reserva: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      developer.log('Error al cancelar reserva: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get filteredBookings {
    return _bookings.where((booking) {
      // Filter out cancelled bookings
      final status = booking['status']?.toString().toLowerCase();
      final cancelledAt = booking['cancelled_at'];
      
      // Skip cancelled bookings
      if (status == 'cancelled' || status == 'canceled' || cancelledAt != null) {
        developer.log('Filtrando reserva cancelada ID: ${booking['id']}, status: $status, cancelled_at: $cancelledAt');
        return false;
      }
      
      final sportId = booking['specific_availability']?['sport_id'];
      
      // Use proper sport name mapping for filtering
      String? sportName;
      if (sportId != null) {
        sportName = _getSportNameFromId(sportId);
      }
      
      bool matchesSport = selectedSport == null ||
                         selectedSport == 'Deporte' ||
                         sportName == selectedSport;
      
      return matchesSport;
    }).toList();
  }

  Map<String, dynamic> _transformBookingForCard(Map<String, dynamic> booking) {
    final availability = booking['specific_availability'];
    final coachName = booking['coach']?['user']?['name'] ?? 'Entrenador desconocido';
    
    // Get sport name using proper mapping
    String sportName = 'Deporte desconocido';
    final sportId = availability?['sport_id'];
    if (sportId != null) {
      sportName = _getSportNameFromId(sportId);
    }
    
    final isOnline = availability?['is_online'] ?? false;
    
    // Parse date
    DateTime? date;
    try {
      final dateStr = availability?['date'];
      if (dateStr != null) {
        date = DateTime.parse(dateStr);
      }
    } catch (e) {
      date = DateTime.now();
    }
    
    // Format times
    String _formatTime(String? timeStr) {
      if (timeStr == null) return '10:00AM';
      try {
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
        // Return default if parsing fails
      }
      return timeStr;
    }
    
    return {
      'date': date ?? DateTime.now(),
      'coach': coachName,
      'sport': sportName,
      'online': isOnline,
      'startTime': _formatTime(availability?['start_time']),
      'endTime': _formatTime(availability?['end_time']),
      'originalBooking': booking, // Keep reference to original data
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = this.filteredBookings;
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Reservas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: selectedSport,
              decoration: _dropdownDecoration('Deporte'),
              items: ['Deporte', ..._sports]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => selectedSport = v),
              dropdownColor: const Color(0xFF4B4949),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.neonBlue,
                      ),
                    )
                  : filteredBookings.isEmpty
                      ? Center(
                          child: Text(
                            'No has hecho reservas todavía',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 22,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBookings,
                          color: AppColors.neonBlue,
                          child: ListView.builder(
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, i) {
                              final booking = filteredBookings[i];
                              final transformedBooking = _transformBookingForCard(booking);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ReservationCard(
                                  reservation: transformedBooking,
                                  onDelete: _cancelBooking,
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF4B4949),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB0B0B0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
    );
  }
} 