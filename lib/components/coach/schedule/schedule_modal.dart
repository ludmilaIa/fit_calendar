import 'package:flutter/material.dart';
import '../../../common/colors.dart';

class AddScheduleModal extends StatefulWidget {
  const AddScheduleModal({super.key});

  @override
  State<AddScheduleModal> createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  String selectedSport = 'Futbol';
  int selectedOnline = 0; // 0: Si, 1: No
  final TextEditingController precioController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize with current date
    selectedDate = DateTime.now();
    dayController.text = selectedDate!.day.toString();
    monthController.text = _getMonthName(selectedDate!.month);
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonBlue,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        dayController.text = selectedDate!.day.toString();
        monthController.text = _getMonthName(selectedDate!.month);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.softBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agregar disponibilidad', 
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Date selection
              const Text('Fecha', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryBlue, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate != null 
                            ? '${selectedDate!.day} de ${_getMonthName(selectedDate!.month)}'
                            : 'Seleccionar fecha',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              const Text('Deporte', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonBlue.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: const Text('Futbol', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
              
              // Custom hours input
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Desde', style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: fromController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ej: 9:00 AM',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hasta', style: TextStyle(color: Colors.white, fontSize: 20)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: toController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ej: 10:00 AM',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Text('Online', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _onlineButton(0, 'Si'),
                  const SizedBox(width: 8),
                  _onlineButton(1, 'No'),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Precio', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              TextField(
                controller: precioController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ingrese el precio',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Ubicación', style: TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 8),
              TextField(
                controller: ubicacionController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ingrese la ubicación',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.neonBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 140,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop({
                          'sport': selectedSport,
                          'from': fromController.text,
                          'to': toController.text,
                          'online': selectedOnline == 0,
                          'precio': precioController.text,
                          'ubicacion': ubicacionController.text,
                          'date': selectedDate,
                          'day': dayController.text,
                          'month': monthController.text,
                        });
                      },
                      child: const Text('Agregar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _onlineButton(int value, String label) {
    bool isSelected = selectedOnline == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOnline = value;
        });
      },
      child: SizedBox(
        width: 40,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonBlue.withOpacity(0.6) : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    precioController.dispose();
    ubicacionController.dispose();
    fromController.dispose();
    toController.dispose();
    dayController.dispose();
    monthController.dispose();
    super.dispose();
  }
} 