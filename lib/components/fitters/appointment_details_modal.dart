import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../common/colors.dart';
import '../../services/booking_service.dart';
import 'reservation_confirmed_modal.dart';

class AppointmentDetailsModal extends StatefulWidget {
  final String date;
  final String timeStart;
  final String timeEnd;
  final bool isOnline;
  final String price;
  final String location;
  final Map<String, dynamic> availability;
  final String coachName;

  const AppointmentDetailsModal({
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.isOnline,
    required this.price,
    required this.location,
    required this.availability,
    required this.coachName,
  });

  @override
  State<AppointmentDetailsModal> createState() => _AppointmentDetailsModalState();
}

class _AppointmentDetailsModalState extends State<AppointmentDetailsModal> {
  final BookingService _bookingService = BookingService();
  bool _isBooking = false;

  Future<void> _createBooking() async {
    setState(() {
      _isBooking = true;
    });

    try {
      // Parse session datetime from availability date and start time
      final dateStr = widget.availability['date']; // "2025-06-15T00:00:00.000000Z"
      final startTimeStr = widget.availability['start_time']; // "09:00:00"
      
      // Parse the date part
      final availabilityDate = DateTime.parse(dateStr);
      
      // Parse the time part
      final timeParts = startTimeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
      
      // Combine date and time in UTC (since the API date comes in UTC)
      final sessionAt = DateTime.utc(
        availabilityDate.year,
        availabilityDate.month,
        availabilityDate.day,
        hour,
        minute,
        second,
      );

      developer.log('Fecha de disponibilidad: $dateStr');
      developer.log('Hora de inicio: $startTimeStr');
      developer.log('Session_at construido: ${sessionAt.toIso8601String()}');

      final result = await _bookingService.createBooking(
        coachId: widget.availability['coach_id'],
        sportId: widget.availability['sport_id'],
        specificAvailabilityId: widget.availability['id'],
        sessionAt: sessionAt,
      );

      if (result['success']) {
        // Close the current modal
        if (mounted) Navigator.of(context).pop();
        
        // Show the confirmation modal
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ReservationConfirmedModal(
            userName: widget.coachName,
            location: widget.location,
            timeRange: '${widget.timeStart}-${widget.timeEnd}',
            date: widget.date,
          ),
        );
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      developer.log('Error al crear booking: $e');
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
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.softBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(32),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: Text(
                      widget.date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Horario',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFA8C7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.timeStart} a ${widget.timeEnd}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Modalidad',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFA8C7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.isOnline ? 'Online' : 'Presencial',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Precio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFA8C7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.price,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            if (!widget.isOnline) ...[
              const SizedBox(height: 16),
              const Text(
                'Ubicación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFA8C7FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.location,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _isBooking ? null : _createBooking,
                child: Container(
                  width: 160,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _isBooking ? Colors.grey : AppColors.neonBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: _isBooking
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Agendar',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 