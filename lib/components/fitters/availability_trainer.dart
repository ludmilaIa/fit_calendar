import 'package:flutter/material.dart';
import '../../common/colors.dart';
import 'date_detail_modal.dart';

class EntrenadorDisponibilidadView extends StatefulWidget {
  final String coachName;
  final List<Map<String, dynamic>> availabilities;
  final int selectedIndex;

  const EntrenadorDisponibilidadView({
    Key? key,
    required this.coachName,
    required this.availabilities,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  State<EntrenadorDisponibilidadView> createState() => _EntrenadorDisponibilidadViewState();
}

class _EntrenadorDisponibilidadViewState extends State<EntrenadorDisponibilidadView> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = null;
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

  Map<String, List<Map<String, dynamic>>> _groupAvailabilitiesByDate() {
    final Map<String, List<Map<String, dynamic>>> groupedAvailabilities = {};
    
    for (var availability in widget.availabilities) {
      final date = availability['date'];
      if (date != null) {
        final formattedDate = _formatDate(date);
        
        if (!groupedAvailabilities.containsKey(formattedDate)) {
          groupedAvailabilities[formattedDate] = [];
        }
        
        groupedAvailabilities[formattedDate]!.add(availability);
      }
    }
    
    return groupedAvailabilities;
  }

  @override
  Widget build(BuildContext context) {
    final groupedAvailabilities = _groupAvailabilitiesByDate();
    final dates = groupedAvailabilities.keys.toList();
    
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E88E5)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.coachName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the IconButton width
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: List.generate(dates.length, (index) {
                  final isSelected = selectedIndex != null && index == selectedIndex;
                  final date = dates[index];
                  final dateAvailabilities = groupedAvailabilities[date]!;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return DateDetailModal(
                            date: date,
                            availabilities: dateAvailabilities,
                            coachName: widget.coachName,
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neonBlue : const Color(0xFFA8C7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        date,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 