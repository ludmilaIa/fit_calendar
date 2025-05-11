import 'package:flutter/material.dart';
import '../../common/colors.dart';
import 'date_detail_modal.dart';

class EntrenadorDisponibilidadView extends StatefulWidget {
  final String coachName;
  final List<String> availableDates;
  final int selectedIndex;

  const EntrenadorDisponibilidadView({
    Key? key,
    required this.coachName,
    required this.availableDates,
    this.selectedIndex = 0,
  }) : super(key: key);

  @override
  State<EntrenadorDisponibilidadView> createState() => _EntrenadorDisponibilidadViewState();
}

class _EntrenadorDisponibilidadViewState extends State<EntrenadorDisponibilidadView> {
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E88E5)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.coachName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // To balance the IconButton width
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Disponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 24,
                runSpacing: 16,
                children: List.generate(widget.availableDates.length, (index) {
                  final isSelected = selectedIndex != null && index == selectedIndex;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                      if (index != null) {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) {
                            return DateDetailModal(date: widget.availableDates[index]);
                          },
                        );
                      }
                    },
                    child: Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.neonBlue : const Color(0xFFA8C7FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.availableDates[index],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 