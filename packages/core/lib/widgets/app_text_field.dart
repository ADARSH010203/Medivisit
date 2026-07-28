import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final int maxLines;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Screen reader label, since design doesn't show visible labels in login, we visually hide it if it's supposed to be hidden. 
        // We will keep it visible but styled correctly if used.
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF494551), // on-surface-variant
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? AppColors.primary : Colors.transparent,
              width: 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      spreadRadius: 4,
                      blurRadius: 0,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11), // slightly smaller than border
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: const Color.fromRGBO(241, 245, 249, 0.6),
              child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  onChanged: widget.onChanged,
                  validator: widget.validator,
                  style: const TextStyle(
                    color: Color(0xFF1D1B20),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF7A7582), // outline color
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.suffixIcon,
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

