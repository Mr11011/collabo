import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final Color? focusedCustomColor;
  final Color? borderColor;

  const CustomTextFormField(
      {Key? key,
      this.labelText,
      this.hintText,
      this.controller,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.validator,
      this.prefixIcon,
      this.suffixIcon,
      this.onSuffixIconPressed,
      this.focusedCustomColor,
      this.borderColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: focusedCustomColor ?? Colors.black)),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixIconPressed,
                icon: Icon(suffixIcon),
              )
            : null,
      ),
    );
  }
}
