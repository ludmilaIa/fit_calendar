import 'package:flutter/material.dart';
import '../../common/colors.dart';
import '../../components/coach/settings/coach_profile.dart';
import '../../components/coach/settings/coach_ranking.dart';

class CoachSettingsScreen extends StatelessWidget {
  const CoachSettingsScreen({super.key});

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
                        const Divider(color: Colors.white24, height: 1),
                        ListTile(
                          title: const Text('Ranking', style: TextStyle(color: Colors.white, fontSize: 16)),
                          trailing: SizedBox(
                            width: 9.75,
                            height: 16.07,
                            child: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CoachRankingView(),
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
                    backgroundColor: AppColors.exitRed.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Handle logout
                  },
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