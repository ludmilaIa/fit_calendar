import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../common/colors.dart';
import '../list/sport.dart';
import '../services/profile_service.dart';
import '../services/sports_service.dart';
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
  String? selectedSport;
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

  // Get available sport names (not already selected by coach)
  List<String> get availableSportNames {
    final selectedSportIds = coachSports.map((s) => s.sportId).toSet();
    return allSportsMapping.entries
        .where((entry) => !selectedSportIds.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
  }

  void _addSelectedSport() async {
    if (selectedSport != null) {
      final String sportToAdd = selectedSport!; // Store the sport name before resetting
      
      // Very first log to confirm function starts
      developer.log('=== STARTING _addSelectedSport for: $sportToAdd ===');
      
      try {
        developer.log('Current coach sports count: ${coachSports.length}');
        
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });

        // Find the sport ID from the name
        final sportId = allSportsMapping.entries
            .firstWhere((entry) => entry.value == selectedSport)
            .key;

        developer.log('Found sport ID: $sportId');

        // Create sport object with default values for profile setup
        final newSport = Sport(
          sportId: sportId,
          specificPrice: 0.0, // Default price, coach can change later
          specificLocation: '', // Default location
          sessionDurationMinutes: 60, // Default duration
        );

        // IMPORTANT: Send ALL existing sports PLUS the new one
        // This prevents the backend from replacing the entire list
        final allSportsToSend = [...coachSports, newSport];

        developer.log('About to send ${allSportsToSend.length} sports to API');

        // Call API to add sport to coach profile
        final result = await _sportsService.createSports(allSportsToSend);

        developer.log('API call completed with success: ${result['success']}');

        if (result['success']) {
          developer.log('About to reload coach sports...');
          // Reload coach sports from backend to get updated data
          await _loadCoachSports();
          developer.log('Reload completed, new count: ${coachSports.length}');
          
          setState(() {
            selectedSport = null; // Reset selection
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$sportToAdd agregado correctamente'), // Use stored value
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          developer.log('API call failed: ${result['error']}');
          setState(() {
            _errorMessage = result['error'] ?? 'Error al agregar el deporte';
            _isLoading = false;
          });
        }
      } catch (e, stackTrace) {
        developer.log('EXCEPTION in _addSelectedSport: $e');
        developer.log('StackTrace: $stackTrace');
        setState(() {
          _errorMessage = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
      
      developer.log('=== ENDING _addSelectedSport ===');
    }
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
    final result = await _profileService.updateProfile(
      age: age,
      description: description,
      token: widget.token,
      // Remove sports from API call for now
      // sports: widget.isCoach ? selectedSports : null,
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
                  
                  // Dropdown para seleccionar deporte
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkGray.withAlpha(77),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSport,
                        isExpanded: true,
                        dropdownColor: AppColors.darkGray,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.gray),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        hint: Text('Seleccionar deporte', style: TextStyle(color: AppColors.gray)),
                        items: availableSportNames
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedSport = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sports Chips
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: coachSports.map((sport) {
                      return SizedBox(
                        width: 107,
                        height: 23,
                        child: GestureDetector(
                          onTap: () {
                            _showDeleteConfirmationDialog(sport);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.neonBlue.withAlpha(153),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getSportName(sport.sportId),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Add Sport Button
                  if (selectedSport != null)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _addSelectedSport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Agregar $selectedSport',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
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