import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color? buttonColor;
  final bool isLoading;

  const CustomButton({
    required this.onPressed,
    required this.text,
    this.buttonColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? const Color(0xFF0F75BC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 25,
          width: 25,
          child: LoadingIndicator(
            indicatorType: Indicator.lineSpinFadeLoader,
            colors: [Colors.grey],
            strokeWidth: 1,
          ),
        )
            : Text(text),
      ),
    );

  }
}
