import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../common/colors.dart';
import '../../components/fitters/trainer_info.dart';
import '../../components/fitters/availability_trainer.dart';
import '../../services/schedule_service.dart';

class FitterExplorarView extends StatefulWidget {
  const FitterExplorarView({Key? key}) : super(key: key);

  @override
  State<FitterExplorarView> createState() => _FitterExplorarViewState();
}

class _FitterExplorarViewState extends State<FitterExplorarView> {
  final ScheduleService _scheduleService = ScheduleService();
  
  String? selectedCoach;
  String? selectedMonth;
  String? selectedSport;
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _availabilities = [];
  Set<String> _coaches = {};
  Set<String> _sports = {};

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

  @override
  void initState() {
    super.initState();
    _loadAvailabilities();
  }

  Future<void> _loadAvailabilities() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _scheduleService.getCoachAvailabilities();
      
      if (!mounted) return;
      
      if (result['success']) {
        final data = result['data'] as List<dynamic>;
        
        setState(() {
          _availabilities = data.map((item) => Map<String, dynamic>.from(item)).toList();
          
          // Extract unique coaches and sports
          _coaches.clear();
          _sports.clear();
          
          for (var availability in _availabilities) {
            // Extract coach name (from coach.user relationship)
            if (availability['coach'] != null && 
                availability['coach']['user'] != null && 
                availability['coach']['user']['name'] != null) {
              _coaches.add(availability['coach']['user']['name']);
            }
            
            // Extract sport name (from sport relationship)
            if (availability['sport'] != null && availability['sport']['name_es'] != null) {
              _sports.add(availability['sport']['name_es']);
            }
          }
        });
        
        developer.log('Disponibilidades cargadas: ${_availabilities.length}');
        developer.log('Coaches encontrados: $_coaches');
        developer.log('Deportes encontrados: $_sports');
      } else {
        developer.log('Error al cargar disponibilidades: ${result['error']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar datos: ${result['error']}'),
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get filteredAvailabilities {
    return _availabilities.where((availability) {
      bool matchesCoach = selectedCoach == null || 
                         selectedCoach == 'Entrenador' ||
                         (availability['coach'] != null && 
                          availability['coach']['user'] != null &&
                          availability['coach']['user']['name'] == selectedCoach);
      
      bool matchesSport = selectedSport == null ||
                         selectedSport == 'Deporte' ||
                         (availability['sport'] != null &&
                          availability['sport']['name_es'] == selectedSport);
      
      bool matchesMonth = selectedMonth == null ||
                         selectedMonth == 'Mes' ||
                         _dateMatchesMonth(availability['date'], selectedMonth!);
      
      return matchesCoach && matchesSport && matchesMonth;
    }).toList();
  }

  bool _dateMatchesMonth(String? dateStr, String monthName) {
    if (dateStr == null) return false;
    
    try {
      final date = DateTime.parse(dateStr);
      final monthIndex = months.indexOf(monthName);
      return monthIndex > 0 && date.month == monthIndex;
    } catch (e) {
      return false;
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupAvailabilitiesByCoachAndSport() {
    final Map<String, List<Map<String, dynamic>>> groupedAvailabilities = {};
    
    for (var availability in filteredAvailabilities) {
      final coachName = availability['coach']?['user']?['name'] ?? 'Entrenador desconocido';
      final sportName = availability['sport']?['name_es'] ?? 'Deporte desconocido';
      final key = '$coachName - $sportName';
      
      if (!groupedAvailabilities.containsKey(key)) {
        groupedAvailabilities[key] = [];
      }
      
      groupedAvailabilities[key]!.add(availability);
    }
    
    return groupedAvailabilities;
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

  String _getCoachSportFromAvailabilities(List<Map<String, dynamic>> availabilities) {
    if (availabilities.isNotEmpty) {
      return availabilities.first['sport']?['name_es'] ?? 'Deporte';
    }
    return 'Deporte';
  }

  String _getCoachNameFromAvailabilities(List<Map<String, dynamic>> availabilities) {
    if (availabilities.isNotEmpty) {
      return availabilities.first['coach']?['user']?['name'] ?? 'Entrenador desconocido';
    }
    return 'Entrenador desconocido';
  }

  @override
  Widget build(BuildContext context) {
    final groupedAvailabilities = _groupAvailabilitiesByCoachAndSport();
    
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
                      value: selectedCoach ?? 'Entrenador',
                      isExpanded: true,
                      dropdownColor: AppColors.cardBackground,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      items: ['Entrenador', ..._coaches].map((String value) {
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
                            value: selectedSport ?? 'Deporte',
                            isExpanded: true,
                            dropdownColor: AppColors.cardBackground,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            items: ['Deporte', ..._sports].map((String value) {
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
              // Loading indicator or coach cards
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.neonBlue,
                        ),
                      )
                    : groupedAvailabilities.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay disponibilidades para los filtros seleccionados',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: groupedAvailabilities.length,
                            itemBuilder: (context, index) {
                              final key = groupedAvailabilities.keys.elementAt(index);
                              final availabilities = groupedAvailabilities[key]!;
                              final coachName = _getCoachNameFromAvailabilities(availabilities);
                              final coachSport = _getCoachSportFromAvailabilities(availabilities);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EntrenadorDisponibilidadView(
                                          coachName: coachName,
                                          availabilities: availabilities,
                                          selectedIndex: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  child: EntrenadorInfoView.infoCard(
                                    name: coachName,
                                    sport: coachSport,
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 