import 'package:flutter/material.dart';

class MeshGradientBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxDim = size.width > size.height ? size.width : size.height;
    final blobSize = maxDim * 1.5;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildBlob(double x, double y, HSLColor hslColor) {
      return Align(
        alignment: FractionalOffset(x, y),
        child: Container(
          width: blobSize,
          height: blobSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                hslColor.toColor(),
                hslColor.toColor().withOpacity(0),
              ],
              stops: const [0.0, 0.5],
            ),
          ),
        ),
      );
    }

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFDF7FF),
      child: Stack(
        children: [
          buildBlob(0.4, 0.2, HSLColor.fromAHSL(1.0, 263, 0.60, isDark ? 0.20 : 0.94)),
          buildBlob(0.8, 0.0, HSLColor.fromAHSL(1.0, 189, 1.0, isDark ? 0.20 : 0.96)),
          buildBlob(0.0, 0.5, HSLColor.fromAHSL(1.0, 263, 0.60, isDark ? 0.20 : 0.94)),
          buildBlob(0.8, 0.5, HSLColor.fromAHSL(1.0, 340, 1.0, isDark ? 0.20 : 0.96)),
          buildBlob(0.0, 1.0, HSLColor.fromAHSL(1.0, 22, 1.0, isDark ? 0.20 : 0.95)),
          buildBlob(0.8, 1.0, HSLColor.fromAHSL(1.0, 242, 1.0, isDark ? 0.20 : 0.95)),
          buildBlob(0.0, 0.0, HSLColor.fromAHSL(1.0, 263, 0.60, isDark ? 0.20 : 0.94)),
          SafeArea(child: child),
        ],
      ),
    );
  }
}

