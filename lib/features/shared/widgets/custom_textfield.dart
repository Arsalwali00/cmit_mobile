import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.obscureText ? _isObscured : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        style: const TextStyle(color: Colors.white, fontSize: 16), // ✅ White input text
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.white), // ✅ White icon
          suffixIcon: widget.obscureText
              ? GestureDetector(
            onTap: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                key: ValueKey<bool>(_isObscured),
                color: Colors.white, // ✅ White visibility icon
              ),
            ),
          )
              : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6), // ✅ Soft hint text
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1), // ✅ Semi-transparent background
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color(0xFF379E4B).withOpacity(0.6),
              width: 1.5,
            ), // ✅ Green border
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF379E4B),
              width: 2.5,
            ), // ✅ Bold green on focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ), // ✅ Red border on error
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2.5,
            ), // ✅ Bolder red on focused error
          ),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 20), // ✅ Comfortable spacing
        ),
      ),
    );
  }
}
