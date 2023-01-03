import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int? maxLength;
  final IconData icon;
  final TextInputType keyboardType;
  final bool showSuffix;
  final bool obscureText;
  final dynamic handler;
  final FocusNode? focusNode;
  const Field(
      {required this.controller,
      required this.label,
      required this.validator,
      required this.maxLength,
      required this.icon,
      required this.keyboardType,
      required this.showSuffix,
      required this.obscureText,
      required this.handler,
      required this.focusNode});
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: TextFormField(
            keyboardType: keyboardType,
            focusNode: (focusNode != null) ? focusNode : null,
            maxLength: maxLength,
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.lightGreenAccent.shade400)),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.redAccent)),
                errorStyle: const TextStyle(color: Colors.redAccent),
                filled: true,
                fillColor: Colors.grey.shade100,
                focusColor: Colors.transparent,
                hoverColor: Colors.transparent,
                label: Text(label),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                // hintText: label,
                suffixIcon: (showSuffix)
                    ? IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(icon),
                        onPressed: handler)
                    : null)),
      ));
}
