import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: width,
        height: 56,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
