import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/reservas/reservation_card.dart';
import '../../services/booking_service.dart';

class CoachReservasView extends StatefulWidget {
  const CoachReservasView({super.key});

  @override
  State<CoachReservasView> createState() => _CoachReservasViewState();
}

class _CoachReservasViewState extends State<CoachReservasView> {
  final BookingService _bookingService = BookingService();
  List<Map<String, dynamic>> bookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? selectedType;

  final List<String> types = ['Todas', 'Confirmadas', 'Pendientes', 'Canceladas'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _bookingService.getBookings();
      
      if (result['success']) {
        final data = result['data'];
        
        setState(() {
          if (data is List) {
            bookings = List<Map<String, dynamic>>.from(data);
          } else {
            bookings = [];
          }
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Error al cargar las reservas';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Center(
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
              // Dropdown Tipo
              Container(
                width: 353,
                height: 51,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    hint: const Text(
                      'Seleccionar tipo',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    isExpanded: true,
                    items: types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Content area
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (bookings.isEmpty) {
      return const Center(
        child: Text(
          'No tienes reservas todavía',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 18,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.primaryBlue,
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return ReservationCard(booking: booking);
        },
      ),
    );
  }
} 