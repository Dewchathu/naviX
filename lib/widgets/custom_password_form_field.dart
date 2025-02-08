import 'package:flutter/material.dart';

class CustomPasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool showSuffixIcon;
  final String? hintText;

  const CustomPasswordFormField({
    required this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.showSuffixIcon = false,
    this.hintText,
  });

  @override
  _CustomPasswordFormFieldState createState() =>
      _CustomPasswordFormFieldState();
}

class _CustomPasswordFormFieldState extends State<CustomPasswordFormField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: (value) {
        widget.onChanged?.call(value);
      },
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: _isObscured,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: widget.hintText,
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.all(14.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0092FF)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0F75BC)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: widget.showSuffixIcon
            ? IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              )
            : null,
      ),
    );
  }
}
