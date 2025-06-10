import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
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
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _showClearButton = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              widget.label, 
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          
        Container(
          width: widget.width,
          height: 50,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: widget.borderColor, width: widget.borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    style: TextStyle(
                      color: widget.foregroundColor,
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                      isDense: true,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: widget.fontSize,
                      ),
                    ),
                  ),
                ),
                if (_showClearButton)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      if (widget.onClear != null) {
                        widget.onClear!();
                      }
                      if (widget.onChanged != null) {
                        widget.onChanged!('');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
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