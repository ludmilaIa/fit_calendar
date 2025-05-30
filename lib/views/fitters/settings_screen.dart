import 'package:flutter/material.dart';
import 'package:fit_calendar/common/colors.dart';
import '../../components/fitters/settings/profile_screen.dart';
import '../../services/auth_service.dart';
import '../../signin.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Configuración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Perfil', style: TextStyle(color: Colors.white, fontSize: 16)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryBlue, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const FitterProfileScreen()),
                          );
                        },
                      ),
                      Divider(color: Colors.grey[400], height: 1, thickness: 1, indent: 12, endIndent: 12),
                      ListTile(
                        title: const Text('Historial', style: TextStyle(color: Colors.white, fontSize: 16)),
                        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryBlue, size: 16),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                // Spacer to push content up
                const Expanded(child: SizedBox()),
              ],
            ),
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
    );
  }
} 