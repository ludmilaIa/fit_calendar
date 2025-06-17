import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../common/colors.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({Key? key}) : super(key: key);

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  final BookingService _bookingService = BookingService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _pastEvents = [];

  @override
  void initState() {
    super.initState();
    _loadPastEvents();
  }

  Future<void> _loadPastEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final result = await _bookingService.getBookings();
      if (result['success']) {
        final now = DateTime.now();
        final data = result['data'] as List<dynamic>;
        final past = data.where((item) {
          final availability = item['specific_availability'];
          final dateStr = availability?['date'];
          if (dateStr == null) return false;
          try {
            final date = DateTime.parse(dateStr);
            return date.isBefore(now);
          } catch (_) {
            return false;
          }
        }).map((item) => Map<String, dynamic>.from(item)).toList();
        setState(() {
          _pastEvents = past;
        });
      } else {
        setState(() {
          _pastEvents = [];
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const monthsSpanish = [
        '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      return '${date.day} de ${monthsSpanish[date.month]}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Atrás',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Historial de eventos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 2),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                        ),
                      )
                    : _pastEvents.isEmpty
                        ? const Center(
                            child: Text(
                              'No tienes eventos pasados',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF464444),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _pastEvents.length,
                              separatorBuilder: (_, __) => Divider(color: Colors.white24, height: 1),
                              itemBuilder: (context, i) {
                                final event = _pastEvents[i];
                                final availability = event['specific_availability'] ?? {};
                                final coachName = event['coach']?['user']?['name'] ?? 'Entrenador';
                                final sportName = availability['sport_name'] ?? availability['sport']?['name_es'] ?? 'Deporte';
                                final dateStr = availability['date'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: Text(
                                          _formatDate(dateStr),
                                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              coachName,
                                              style: const TextStyle(color: Colors.white, fontSize: 16),
                                            ),
                                            Text(
                                              sportName,
                                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 