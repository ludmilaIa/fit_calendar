import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/settings/coach_profile.dart';
import '../../services/auth_service.dart';
import '../../signin.dart';

class CoachSettingsScreen extends StatefulWidget {
  const CoachSettingsScreen({super.key});

  @override
  State<CoachSettingsScreen> createState() => _CoachSettingsScreenState();
}

class _CoachSettingsScreenState extends State<CoachSettingsScreen> {
  final authService = AuthService();

  Future<void> handleLogout() async {
    try {
      final response = await authService.logout();
      
      if (!mounted) return;
      
      if (response['success']) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SignInView()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Error al cerrar sesión'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 32),
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
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Perfil', style: TextStyle(color: Colors.white, fontSize: 16)),
                          trailing: SizedBox(
                            width: 9.75,
                            height: 16.07,
                            child: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoachProfileView(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: SizedBox(
                width: 107,
                height: 63,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.exitRed.withAlpha(77),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: handleLogout,
                  child: const Text(
                    'Salir',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 