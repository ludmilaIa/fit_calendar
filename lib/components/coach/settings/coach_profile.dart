import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../common/colors.dart';
import '../../../services/profile_service.dart';
import '../../../services/sports_service.dart';
import 'sport_modal.dart';

class CoachProfileView extends StatefulWidget {
  const CoachProfileView({super.key});

  @override
  State<CoachProfileView> createState() => _CoachProfileViewState();
}

class _CoachProfileViewState extends State<CoachProfileView> {
  final ProfileService _profileService = ProfileService();
  final SportsService _sportsService = SportsService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _profileData;
  List<Sport> _sports = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadSports();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _profileService.getCoachProfileWithUser();
      
      if (result['success']) {
        final data = result['data'];
        
        // Debug logging to see the structure
        developer.log('Coach profile data: $data');
        developer.log('Available keys: ${data.keys.toList()}');
        
        setState(() {
          _profileData = data;
          
          // Now we should have the name directly from the combined data
          _nameController.text = data['name'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          
          developer.log('Mapped name: ${data['name']}');
          developer.log('Mapped description: ${data['description']}');
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Error al cargar el perfil';
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

  Future<void> _loadSports() async {
    try {
      final result = await _sportsService.getCoachSports();
      
      if (result['success']) {
        final data = result['data'];
        developer.log('Sports data received: $data');
        
        setState(() {
          if (data['sports'] != null && data['sports'] is List) {
            _sports = (data['sports'] as List)
                .map((sportJson) => Sport.fromJson(sportJson))
                .toList();
          } else {
            _sports = [];
          }
        });
        
        developer.log('Loaded ${_sports.length} sports');
      } else {
        developer.log('Error loading sports: ${result['error']}');
        // Don't show error for sports, just keep empty list
        setState(() {
          _sports = [];
        });
      }
    } catch (e) {
      developer.log('Exception loading sports: $e');
      setState(() {
        _sports = [];
      });
    }
  }

  void _onSportAdded(Sport sport) {
    setState(() {
      _sports.add(sport);
    });
    // Reload sports to get the complete data from server
    _loadSports();
  }

  void _onSportError() {
    // Could show additional error handling here if needed
    developer.log('Error adding sport');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Atrás',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Configuración',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Perfil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: Colors.red),
                              onPressed: _loadProfile,
                            ),
                          ],
                        ),
                      ),
                    Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 101,
                            height: 95,
                            child: CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: const Icon(Icons.person, size: 64, color: Colors.black54),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 101,
                            height: 22,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Editar',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Nombre y Apellidos',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _nameController,
                        enabled: false,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Descripción',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        enabled: false,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Entrenador de:',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sports.isEmpty 
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
                              : _sports.map((sport) => Container(
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
                                        sport.specificLocation,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '\$${sport.specificPrice.toStringAsFixed(2)} - ${sport.sessionDurationMinutes}min',
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
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
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
      ),
    );
  }
} 