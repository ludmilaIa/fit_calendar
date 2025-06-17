import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../common/colors.dart';
import '../services/profile_service.dart';
import '../services/sports_service.dart';
import '../components/coach/settings/sport_modal.dart';
import 'trainer_view.dart';
import 'fitter_view.dart';

class ProfileSetupView extends StatefulWidget {
  final String token;
  final String email;
  final bool isCoach; // Determina si es un coach o un fitter

  const ProfileSetupView({
    super.key, 
    required this.token, 
    required this.email,
    required this.isCoach,
  });

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final ProfileService _profileService = ProfileService();
  final SportsService _sportsService = SportsService();
  
  // Changed to store sport objects with complete data from backend
  List<Sport> coachSports = [];
  Map<int, String> allSportsMapping = {}; // Map sport ID to name
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    developer.log('=== ProfileSetupView initState ===');
    if (widget.isCoach) {
      developer.log('Loading data for coach...');
      _loadAllSports();
      _loadCoachSports();
    }
  }

  // Load all available sports for the dropdown
  Future<void> _loadAllSports() async {
    try {
      final result = await _sportsService.getAllSports();
      
      if (result['success']) {
        final data = result['data'];
        setState(() {
          if (data is List) {
            allSportsMapping = {};
            for (var sport in data) {
              final id = sport['id'] as int?;
              final name = sport['name_es'] as String?;
              if (id != null && name != null) {
                allSportsMapping[id] = name;
              }
            }
          }
        });
      }
    } catch (e) {
      developer.log('Error loading all sports: $e');
    }
  }

  // Load coach's current sports from backend
  Future<void> _loadCoachSports() async {
    try {
      final result = await _profileService.getCoachProfileWithSports();
      
      if (result['success']) {
        final data = result['data'];
        developer.log('Coach sports data received: $data'); // Debug logging
        setState(() {
          if (data['sports'] != null && data['sports'] is List) {
            coachSports = (data['sports'] as List)
                .map((sportJson) {
                  developer.log('Processing sport JSON: $sportJson'); // Debug logging
                  // Handle the pivot structure from the coach response
                  if (sportJson['pivot'] != null) {
                    return Sport(
                      id: sportJson['pivot']['id'] ?? sportJson['pivot']['sport_id'], // Use the pivot's actual ID or fallback
                      sportId: sportJson['id'], // This is the sport catalog ID
                      specificPrice: double.parse(sportJson['pivot']['specific_price'].toString()),
                      specificLocation: sportJson['pivot']['specific_location'] ?? '',
                      sessionDurationMinutes: sportJson['pivot']['session_duration_minutes'] ?? 60,
                    );
                  } else {
                    return Sport.fromJson(sportJson);
                  }
                })
                .toList();
            developer.log('Mapped ${coachSports.length} coach sports'); // Debug logging
          } else {
            developer.log('No sports data found in response'); // Debug logging
            coachSports = [];
          }
        });
      } else {
        developer.log('Error in API response: ${result['error']}'); // Debug logging
      }
    } catch (e) {
      developer.log('Error loading coach sports: $e');
    }
  }

  // Get sport name from ID using the mapping
  String _getSportName(int? sportId) {
    if (sportId == null) return 'Deporte desconocido';
    return allSportsMapping[sportId] ?? 'Deporte ID $sportId';
  }

  void _onSportAdded(Sport sport) {
    // En lugar de recargar todo el perfil, agregamos el nuevo deporte a la lista existente
    setState(() {
      // Verificar que el deporte no esté ya en la lista para evitar duplicados
      bool sportExists = coachSports.any((existingSport) => existingSport.sportId == sport.sportId);
      if (!sportExists) {
        coachSports.add(sport);
        developer.log('Deporte agregado a la UI: ${_getSportName(sport.sportId)} (ID: ${sport.sportId})');
      } else {
        developer.log('Deporte ya existe en la lista: ${_getSportName(sport.sportId)}');
      }
    });
    
    // Opcionalmente, podemos hacer una recarga en segundo plano para sincronizar
    // pero sin sobrescribir la UI hasta confirmar que tenemos todos los deportes
    _loadCoachSports();
  }

  void _onSportError() {
    // Could show additional error handling here if needed
    developer.log('Error adding sport');
  }

  void _showDeleteConfirmationDialog(Sport sport) {
    final sportName = _getSportName(sport.sportId);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.darkGray,
          title: const Text(
            '¿Desea eliminar este deporte?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Se eliminará "$sportName" de su perfil',
            style: TextStyle(color: AppColors.gray),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.gray.withAlpha(51),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _deleteSport(sport);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(153),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSport(Sport sport) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _profileService.deleteSport(sport.id.toString());
      
      if (result['success']) {
        // Reload coach sports from backend to get updated data
        await _loadCoachSports();
        setState(() {
          _isLoading = false;
        });
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_getSportName(sport.sportId)} eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Error al eliminar el deporte';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  void _handleProfileCreation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    // Convertir edad a int si no está vacío
    int? age;
    if (_ageController.text.isNotEmpty) {
      age = int.tryParse(_ageController.text);
    }
    
    // Obtener descripción si no está vacía
    String? description;
    if (_descriptionController.text.isNotEmpty) {
      description = _descriptionController.text;
    }
    
    // Actualizar perfil en el API
    final result = await _profileService.updateUserProfile(
      age: age,
      description: description,
    );
    
    if (result['success']) {
      // Navegar a la vista principal con navbar según el rol
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => widget.isCoach 
            ? const TrainerView() 
            : const FitterView()
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Error al actualizar el perfil';
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  "Complete sus datos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Profile Picture Placeholder
                SizedBox(
                  width: 101,
                  height: 95,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[400],
                    child: const Icon(Icons.person, size: 70, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Add Photo Button
                SizedBox(
                  width: 101,
                  height: 22,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Agregar',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Age Field
                TextField(
                  controller: _ageController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Edad',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray.withAlpha(77),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description Field
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Descripción de sí mismo',
                    hintStyle: TextStyle(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.darkGray.withAlpha(77),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                    ),
                  ),
                ),
                
                // Sports Training Section (solo para coaches)
                if (widget.isCoach) ...[
                  const SizedBox(height: 32),
                  const Text(
                    "Entrenador de:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sports section with same format as coach_profile
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: coachSports.isEmpty 
                            ? [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[600],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Sin deportes asignados',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ]
                            : coachSports.map((sport) => GestureDetector(
                                onTap: () {
                                  _showDeleteConfirmationDialog(sport);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _getSportName(sport.sportId),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '\$${sport.specificPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.neonBlue),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddSportModal(
                                onSportAdded: _onSportAdded,
                                onError: _onSportError,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
                
                // Error message if exists
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 48),
                
                // Create Account Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleProfileCreation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 