import 'package:flutter/material.dart';
import '../../components/fitters/booking/reservation_card.dart';

class FitterReservationsScreen extends StatefulWidget {
  const FitterReservationsScreen({super.key});

  @override
  State<FitterReservationsScreen> createState() => _FitterReservationsScreenState();
}

class _FitterReservationsScreenState extends State<FitterReservationsScreen> {
  String? selectedCoach;
  String? selectedMonth;
  String? selectedSport;

  // Mock data for demonstration
  final List<Map<String, dynamic>> reservations = [
    {
      'date': DateTime(2024, 4, 11),
      'coach': 'Emiliano Martinez',
      'sport': 'Futbol',
      'online': false,
      'startTime': '10:00AM',
      'endTime': '11:00AM',
    },
  ];

  final List<String> coaches = ['Emiliano Martinez', 'Lionel Messi'];
  final List<String> months = ['Abril', 'Mayo', 'Junio'];
  final List<String> sports = ['Futbol', 'Tenis', 'Padel'];

  @override
  Widget build(BuildContext context) {
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
              value: selectedCoach,
              decoration: _dropdownDecoration('Entrenador'),
              items: coaches
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCoach = v),
              dropdownColor: const Color(0xFF4B4949),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedMonth,
                    decoration: _dropdownDecoration('Mes'),
                    items: months
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedMonth = v),
                    dropdownColor: const Color(0xFF4B4949),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSport,
                    decoration: _dropdownDecoration('Deporte'),
                    items: sports
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedSport = v),
                    dropdownColor: const Color(0xFF4B4949),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: reservations.isEmpty
                  ? Center(
                      child: Text(
                        'No has hecho reservas todavia',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 22,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: reservations.length,
                      itemBuilder: (context, i) {
                        final r = reservations[i];
                        return ReservationCard(reservation: r);
                      },
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