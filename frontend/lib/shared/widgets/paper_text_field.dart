import 'package:flutter/material.dart';

class PaperTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final int maxLines;

  const PaperTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}