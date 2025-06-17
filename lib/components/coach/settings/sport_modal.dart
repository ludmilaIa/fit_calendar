import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../common/colors.dart';
import '../../../services/sports_service.dart';
import '../../../list/sport.dart';

class AddSportModal extends StatefulWidget {
  final Function(Sport)? onSportAdded;
  final VoidCallback? onError;

  const AddSportModal({super.key, this.onSportAdded, this.onError});

  @override
  State<AddSportModal> createState() => _AddSportModalState();
}

class _AddSportModalState extends State<AddSportModal> {
  final TextEditingController _priceController = TextEditingController();
  final SportsService _sportsService = SportsService();
  bool _isLoading = false;
  String? _selectedSport;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _addSport() async {
    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona un deporte'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un precio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? price = double.tryParse(_priceController.text);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un precio válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Encontrar el ID del deporte seleccionado
      final selectedSportData = availableSports.firstWhere(
        (sport) => sport['name'] == _selectedSport,
      );

      final sport = Sport(
        sportId: selectedSportData['id'] as int,
        specificPrice: price,
        specificLocation: '', // Provide empty string as default
        sessionDurationMinutes: 60, // Provide 60 minutes as default
      );

      final result = await _sportsService.createSports([sport]);

      if (result['success']) {
        if (widget.onSportAdded != null) {
          widget.onSportAdded!(sport);
        }
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deporte agregado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (widget.onError != null) {
          widget.onError!();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al agregar el deporte'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (widget.onError != null) {
        widget.onError!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSportDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deporte',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedSport,
            dropdownColor: Colors.grey[700],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintText: 'Selecciona un deporte',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            items: availableSports.map((sport) {
              return DropdownMenuItem<String>(
                value: sport['name'] as String,
                child: Text(
                  sport['name'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedSport = value;
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Añadir deporte',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSportDropdown(),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _priceController,
              label: 'Precio específico',
              hint: 'Ej: 35.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 140,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _addSport,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : const Text(
                            'Agregar',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 