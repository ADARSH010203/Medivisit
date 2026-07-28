import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed; // nullable — disabled when null
  final bool isLoading;
  final double width;
  final List<Color>? colors; // optional gradient override

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
    this.colors,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null && !widget.isLoading;
    final gradient = widget.colors != null
        ? LinearGradient(colors: widget.colors!)
        : AppColors.brandGradient;

    return GestureDetector(
      onTapDown:
          disabled ? null : (_) { if (!widget.isLoading) _controller.forward(); },
      onTapUp: disabled
          ? null
          : (_) {
              if (!widget.isLoading) {
                _controller.reverse();
                widget.onPressed?.call();
              }
            },
      onTapCancel:
          disabled ? null : () { if (!widget.isLoading) _controller.reverse(); },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Container(
            width: widget.width,
            height: 56,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: disabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
