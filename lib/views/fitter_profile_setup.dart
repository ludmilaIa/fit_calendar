import 'package:flutter/material.dart';
import '../common/colors.dart';

class FitterProfileSetupView extends StatefulWidget {
  const FitterProfileSetupView({super.key});

  @override
  State<FitterProfileSetupView> createState() => _FitterProfileSetupViewState();
}

class _FitterProfileSetupViewState extends State<FitterProfileSetupView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
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
              
              // Name Field
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nombre y apellidos',
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
              const SizedBox(height: 24),
              
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
              
              // Spacer to push "Create Account" button to bottom
              const Spacer(),
              
              // Create Account Button
              ElevatedButton(
                onPressed: () {
                  // Handle account creation and navigate to main app
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const DashboardPlaceholder()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonBlue,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
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