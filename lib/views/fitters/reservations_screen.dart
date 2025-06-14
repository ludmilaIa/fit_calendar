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
          
          // Extract unique sports
          _sports.clear();
          
          for (var booking in _bookings) {
            // Extract sport name - try different possible locations
            String? sportName;
            // Try specific_availability.sport first
            sportName = booking['specific_availability']?['sport']?['name_es'];
            // If not found, we might need to look elsewhere or use sport_id
            if (sportName == null) {
              final sportId = booking['specific_availability']?['sport_id'];
              // Map common sport IDs to names (fallback)
              if (sportId == 1) {
                sportName = 'Fútbol';
              } else if (sportId != null) {
                sportName = 'Deporte $sportId';
              }
            }
            
            if (sportName != null) {
              _sports.add(sportName);
            }
          }
        });
        
        developer.log('Reservas cargadas: ${_bookings.length}');
        developer.log('Deportes encontrados: $_sports');
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

  List<Map<String, dynamic>> get filteredBookings {
    return _bookings.where((booking) {
      final sportId = booking['specific_availability']?['sport_id'];
      
      // Map sport ID to name for filtering
      String? sportName;
      if (sportId == 1) {
        sportName = 'Fútbol';
      } else if (sportId != null) {
        sportName = 'Deporte $sportId';
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
    
    // Get sport name from sport_id
    String sportName = 'Deporte desconocido';
    final sportId = availability?['sport_id'];
    if (sportId == 1) {
      sportName = 'Fútbol';
    } else if (sportId != null) {
      sportName = 'Deporte $sportId';
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