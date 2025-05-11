import 'package:flutter/material.dart';
import '../../common/colors.dart';

class EntrenadorInfoView extends StatelessWidget {
  final String name;
  final String sport;

  const EntrenadorInfoView({
    Key? key,
    required this.name,
    required this.sport,
  }) : super(key: key);

  static Widget infoCard({required String name, required String sport}) {
    return Center(
      child: Container(
        width: 366,
        height: 67,
        decoration: BoxDecoration(
          color: const Color(0xFFA8C7FF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkGray.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sport,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      appBar: AppBar(
        backgroundColor: AppColors.softBlack,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Entrenador',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: infoCard(name: name, sport: sport),
      ),
    );
  }
} 