import 'dart:ui';
import 'package:flutter/material.dart';

class AdminGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double width;
  final double? height;

  const AdminGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.width = double.infinity,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          // Inner cyan glow simulation
          BoxShadow(
            color: const Color(0xFF38BDF8).withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 1,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            color: Colors.white.withOpacity(0.03),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
