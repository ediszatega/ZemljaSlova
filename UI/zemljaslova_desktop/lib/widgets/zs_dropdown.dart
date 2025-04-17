import 'package:flutter/material.dart';

class ZSDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double width;

  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final double paddingHorizontal;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double fontSize;
  final FontWeight fontWeight;

  const ZSDropdown({
    super.key,
    this.label = "",
    required this.value,
    required this.items,
    required this.onChanged,
    this.width = 200,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.elevation = 0,
    this.paddingHorizontal = 12,
    this.borderRadius = 4,
    this.borderWidth = 1,
    this.borderColor = Colors.grey,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              label, 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          
        SizedBox(
          width: width,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  items: items,
                  onChanged: onChanged,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  elevation: elevation.toInt(),
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 