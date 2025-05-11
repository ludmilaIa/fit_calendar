import 'package:flutter/material.dart';
import 'package:fit_calendar/common/colors.dart';
import '../../components/fitters/settings/profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  backgroundColor: AppColors.exitRed.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
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