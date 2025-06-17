import 'package:flutter/material.dart';
import '../../../common/colors.dart';
import '../../../services/sports_service.dart';
import 'dart:developer' as developer;

class AddScheduleModal extends StatefulWidget {
  final List<Sport>? coachSports; // Deportes del coach

  const AddScheduleModal({super.key, this.coachSports});

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  String? selectedSport;
  int selectedOnline = 0; // 0: Si, 1: No
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  DateTime? selectedDate;
  
  final SportsService _sportsService = SportsService();
  Map<int, String> _sportsMapping = {};
  List<String> _coachSportNames = [];
  bool _isLoadingSports = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    selectedDate = DateTime.now();
    dayController.text = selectedDate!.day.toString();
    monthController.text = _getMonthName(selectedDate!.month);
    _loadSports();
  }

  Future<void> _loadSports() async {
    setState(() {
      _isLoadingSports = true;
    });

    try {
      // Primero obtener el mapeo de todos los deportes para convertir IDs a nombres
      final result = await _sportsService.getAllSports();
      
      if (result['success']) {
        final data = result['data'];
        developer.log('All sports data received: $data');
        
        // Crear mapeo de ID a nombre
        if (data is List) {
          _sportsMapping = {};
          for (var sport in data) {
            final id = sport['id'] as int?;
            final name = sport['name_es'] as String?;
            if (id != null && name != null) {
              _sportsMapping[id] = name;
            }
          }
        }

        // Ahora filtrar solo los deportes del coach
        setState(() {
          _coachSportNames = [];
          if (widget.coachSports != null && widget.coachSports!.isNotEmpty) {
            developer.log('Coach sports received: ${widget.coachSports!.length} deportes');
            for (var coachSport in widget.coachSports!) {
              developer.log('Processing coach sport: ID=${coachSport.sportId}, Looking up in mapping...');
              final sportName = _sportsMapping[coachSport.sportId];
              if (sportName != null) {
                if (!_coachSportNames.contains(sportName)) {
                  _coachSportNames.add(sportName);
                  developer.log('Added sport: $sportName');
                } else {
                  developer.log('Sport already added: $sportName');
                }
              } else {
                // Si no encontramos el nombre en el mapeo, agregamos un fallback
                final fallbackName = 'Deporte ID ${coachSport.sportId}';
                if (!_coachSportNames.contains(fallbackName)) {
                  _coachSportNames.add(fallbackName);
                  developer.log('Added fallback sport: $fallbackName');
                }
              }
            }
          } else {
            developer.log('No coach sports received or empty list');
          }
        });
        
        developer.log('Coach sports names: $_coachSportNames');
      } else {
        developer.log('Error loading sports: ${result['error']}');
        // Si no se pueden cargar, usar solo los nombres por defecto
        setState(() {
          _coachSportNames = [];
          if (widget.coachSports != null) {
            for (var coachSport in widget.coachSports!) {
              _coachSportNames.add('Deporte ID ${coachSport.sportId}');
            }
          }
        });
      }
    } catch (e) {
      developer.log('Exception loading sports: $e');
      setState(() {
        _coachSportNames = [];
      });
    } finally {
      setState(() {
        _isLoadingSports = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonBlue,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dayController.text = selectedDate!.day.toString();
        monthController.text = _getMonthName(selectedDate!.month);
      });
    }
  }

  Widget _buildSportDropdown() {
    if (_isLoadingSports) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryBlue, width: 1),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonBlue),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Cargando deportes...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_coachSportNames.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange, width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No tienes deportes asociados. Agrega deportes en tu perfil primero.',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryBlue, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSport,
          isExpanded: true,
          dropdownColor: AppColors.cardBackground,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          hint: const Text(
            'Selecciona un deporte',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          items: _coachSportNames.map((String sportName) {
            return DropdownMenuItem<String>(
              value: sportName,
              child: Text(
                sportName,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            setState(() {
              selectedSport = value;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.softBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agregar disponibilidad', 
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Date selection
              const Text('Fecha', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryBlue, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null 
                            ? '${selectedDate!.day} de ${_getMonthName(selectedDate!.month)}'
                            : 'Seleccionar fecha',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Sport dropdown
              const Text('Deporte', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              _buildSportDropdown(),
              const SizedBox(height: 20),
              
              // Custom hours input
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Desde', style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: fromController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ej: 9:00 AM',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hasta', style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: toController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ej: 10:00 AM',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Text('Online', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _onlineButton(0, 'Si'),
                  const SizedBox(width: 8),
                  _onlineButton(1, 'No'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Ubicación', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              TextField(
                controller: ubicacionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ingrese la ubicación',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 140,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: selectedSport != null && !_isLoadingSports && _coachSportNames.isNotEmpty ? () {
                        Navigator.of(context).pop({
                          'sport': selectedSport,
                          'from': fromController.text,
                          'to': toController.text,
                          'online': selectedOnline == 0,
                          'ubicacion': ubicacionController.text,
                          'date': selectedDate,
                          'day': dayController.text,
                          'month': monthController.text,
                        });
                      } : null,
                      child: const Text('Agregar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onlineButton(int value, String label) {
    bool isSelected = selectedOnline == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOnline = value;
        });
      },
      child: SizedBox(
        width: 40,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonBlue.withOpacity(0.6) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ubicacionController.dispose();
    fromController.dispose();
    toController.dispose();
    dayController.dispose();
    monthController.dispose();
    super.dispose();
  }
} 