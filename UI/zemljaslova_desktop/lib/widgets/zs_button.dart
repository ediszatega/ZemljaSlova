import 'package:flutter/material.dart';

class ZSButton extends StatelessWidget {
  final String text;
  final String label;

  final Color backgroundColor;
  final Color foregroundColor;
  final double elevation;
  final double paddingHorizontal;
  final double paddingVertical;
  final double topPadding;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final double fontSize;
  final FontWeight fontWeight;
  final double? width;

  final VoidCallback onPressed;

  const ZSButton({
    super.key,
    required this.text,
    this.label = "",
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.elevation = 0,
    this.paddingHorizontal = 20,
    this.paddingVertical = 16,
    this.topPadding = 0,
    this.borderRadius = 4,
    this.borderWidth = 1,
    this.borderColor = Colors.grey,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w400,
    this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label, 
            style: TextStyle(fontSize: 12, color: Colors.black),
          )
        else if (topPadding > 0)
          SizedBox(height: topPadding)
        else
          const SizedBox(height: 16),

        const SizedBox(height: 4),

        width != null
            ? SizedBox(
                width: width,
                child: _buildButton(),
              )
            : _buildButton(),
      ],
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

