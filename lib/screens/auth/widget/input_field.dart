import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;

  const InputField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // withOpacity is deprecated; use withAlpha for similar effect
        color: Colors.white.withAlpha(13),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          // withOpacity is deprecated; use withAlpha for similar effect
          hintStyle: TextStyle(color: Colors.white.withAlpha(97)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          suffixIcon: obscure
              ? const Icon(Icons.visibility_off, color: Colors.white54)
              : null,
        ),
      ),
    );
  }
}
