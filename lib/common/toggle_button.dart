import 'package:flutter/material.dart';
import 'colors.dart';

class CustomToggleButton extends StatelessWidget {
  final bool isSelected;
  final Function(bool) onToggle;
  final String text;
  final double width;
  final double height;

  const CustomToggleButton({
    super.key,
    required this.isSelected,
    required this.onToggle,
    required this.text,
    this.width = 120,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(!isSelected),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.neonBlue : AppColors.primaryBlue,
            width: 2,
          ),
          color: isSelected 
            ? AppColors.neonBlue.withOpacity(0.2)
            : AppColors.darkGray.withOpacity(0.3),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? AppColors.neonBlue : Colors.white,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// Example of how to use multiple toggle buttons in a group
class ToggleButtonGroup extends StatefulWidget {
  final List<String> options;
  final Function(int) onOptionSelected;
  final int initialSelection;

  const ToggleButtonGroup({
    super.key,
    required this.options,
    required this.onOptionSelected,
    this.initialSelection = 0,
  });

  @override
  State<ToggleButtonGroup> createState() => _ToggleButtonGroupState();
}

class _ToggleButtonGroupState extends State<ToggleButtonGroup> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.options.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomToggleButton(
            isSelected: selectedIndex == index,
            onToggle: (selected) {
              if (selected) {
                setState(() => selectedIndex = index);
                widget.onOptionSelected(index);
              }
            },
            text: widget.options[index],
          ),
        ),
      ),
    );
  }
}
