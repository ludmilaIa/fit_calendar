import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/fitters/trainer_info.dart';
import '../../components/fitters/availability_trainer.dart';

class FitterExplorarView extends StatefulWidget {
  const FitterExplorarView({Key? key}) : super(key: key);

  @override
  State<FitterExplorarView> createState() => _FitterExplorarViewState();
}

class _FitterExplorarViewState extends State<FitterExplorarView> {
  String? selectedCoach;
  String? selectedMonth;
  String? selectedSport;

  final List<String> coaches = [
    'Entrenador',
    'Emiliano Martinez',
    'Monica Rodriguez',
  ];

  final List<String> months = [
    'Mes',
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  final List<String> sports = [
    'Deporte',
    'Fútbol',
    'Basket',
    'Tennis',
    'Natación',
    'Strength',
  ];

  final List<Map<String, String>> playerCards = [
    {
      'name': 'Emiliano Martinez',
      'sport': 'Futbol',
    },
    {
      'name': 'Monica Rodriguez',
      'sport': 'Strength',
    },
  ];

  @override
  Widget build(BuildContext context) {
    String? coachSport;
    if (selectedCoach == 'Emiliano Martinez') coachSport = 'Futbol';
    if (selectedCoach == 'Monica Rodriguez') coachSport = 'Strength';
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Explorar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 24),
              // Coach Dropdown
              Center(
                child: Container(
                  width: 353,
                  height: 51,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCoach ?? coaches[0],
                      isExpanded: true,
                      dropdownColor: AppColors.cardBackground,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      items: coaches.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: value == 'Entrenador' ? 14 : 18,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCoach = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Month & Sport Dropdowns
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 51,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMonth ?? months[0],
                            isExpanded: true,
                            dropdownColor: AppColors.cardBackground,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            items: months.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: value == 'Mes' ? 14 : 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 158,
                        height: 51,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSport ?? sports[0],
                            isExpanded: true,
                            dropdownColor: AppColors.cardBackground,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            items: sports.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: value == 'Deporte' ? 14 : 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedSport = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntrenadorDisponibilidadView(
                            coachName: 'Emiliano Martinez',
                            availableDates: [
                              '10 de Mayo',
                              '11 de Mayo',
                              '12 de Mayo',
                            ],
                            selectedIndex: 2,
                          ),
                        ),
                      );
                    },
                    child: EntrenadorInfoView.infoCard(name: 'Emiliano Martinez', sport: 'Futbol'),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntrenadorDisponibilidadView(
                            coachName: 'Monica Rodriguez',
                            availableDates: [
                              '15 de Mayo',
                              '16 de Mayo',
                              '17 de Mayo',
                            ],
                            selectedIndex: 0,
                          ),
                        ),
                      );
                    },
                    child: EntrenadorInfoView.infoCard(name: 'Monica Rodriguez', sport: 'Strength'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 