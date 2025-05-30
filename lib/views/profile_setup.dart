import 'package:flutter/material.dart';
import '../common/colors.dart';
import '../list/sport.dart';
import '../services/profile_service.dart';
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
  List<String> selectedSports = [];
  bool _isLoading = false;
  String? selectedSport;
  String? _errorMessage;
  
  // Lista de deportes disponibles from the imported file
  
  void _addSelectedSport() {
    if (selectedSport != null && !selectedSports.contains(selectedSport)) {
      setState(() {
        selectedSports.add(selectedSport!);
        selectedSport = null; // Reset selection after adding
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
                        items: availableSports
                            .where((sport) => !selectedSports.contains(sport))
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
                          
                          if (value != null) {
                            _addSelectedSport();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sports Chips
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: selectedSports.map((sport) {
                      return SizedBox(
                        width: 107,
                        height: 23,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.neonBlue.withAlpha(153),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            sport,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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