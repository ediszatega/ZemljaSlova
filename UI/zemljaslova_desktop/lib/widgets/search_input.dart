import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  final String label;
  final String hintText;
  final double width;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double fontSize;
  final FontWeight fontWeight;

  const SearchInput({
    super.key,
    this.label = "",
    this.hintText = "Pretraži",
    this.width = double.infinity,
    this.controller,
    this.onChanged,
    this.onClear,
    this.focusNode,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
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
          
        Container(
          width: width,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                      isDense: true,
                    ),
                  ),
                ),
                if (controller != null && controller!.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      controller!.clear();
                      if (onClear != null) {
                        onClear!();
                      }
                      if (onChanged != null) {
                        onChanged!('');
                      }
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 