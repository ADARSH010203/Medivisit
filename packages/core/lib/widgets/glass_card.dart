import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final int level; // 0 to 3
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.level = 2,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    double blur = 20.0;
    double opacity = 0.7;
    double borderOpacity = 0.8;

    switch (level) {
      case 0:
        blur = 0;
        opacity = 0;
        borderOpacity = 0;
        break;
      case 1:
        blur = 10;
        opacity = 0.8;
        borderOpacity = 0.6;
        break;
      case 2:
        blur = 16;
        opacity = 0.7;
        borderOpacity = 0.5;
        break;
      case 3:
        blur = 24;
        opacity = 0.5;
        borderOpacity = 0.4;
        break;
    }

    final color = Colors.white; // Glass is always white base in light theme

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (level > 0)
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              border: Border.all(
                color: color.withOpacity(borderOpacity),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
