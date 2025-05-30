import 'package:flutter/material.dart';
import '../common/colors.dart';
import '../components/coach/settings/sport_modal.dart';

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
  List<String> selectedSports = [];
  bool _isLoading = false;
  
  void _addSport() {
    final TextEditingController sportController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AddSportModal(
          controller: sportController,
          onAdd: () {
            // Add sport if not empty and not already added
            if (sportController.text.isNotEmpty && 
                !selectedSports.contains(sportController.text)) {
              setState(() {
                selectedSports.add(sportController.text);
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _handleProfileCreation() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulamos un pequeño retraso
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // Navegar a dashboard (simulado)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPlaceholder()),
        (route) => false,
      );
    });
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
                  Row(
                    children: [
                      const Text(
                        "Entrenador de:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: AppColors.neonBlue,
                          size: 25,
                        ),
                        onPressed: _addSport,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
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

// Temporary placeholder for dashboard
class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.darkBlue,
      ),
      body: const Center(
        child: Text(
          'Cuenta creada exitosamente',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
} 