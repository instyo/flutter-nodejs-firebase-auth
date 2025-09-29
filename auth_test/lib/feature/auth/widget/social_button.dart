import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final VoidCallback onPressed;

  const SocialButton({
    super.key,
    this.icon,
    required this.onPressed,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: imagePath != null
            ? Image.asset(imagePath!, width: 18, height: 18)
            : Icon(
                icon,
                color: icon == Icons.facebook
                    ? const Color(0xFF1877F2)
                    : const Color(0xFFDB4437),
                size: 24,
              ),
      ),
    );
  }
}
