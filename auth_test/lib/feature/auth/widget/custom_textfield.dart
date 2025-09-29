import 'package:flutter/material.dart';

class CustomTextfield extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController? controller;

  const CustomTextfield({super.key, 
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF374151),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEBF4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(icon, color: Color(0xFF2563EB)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
