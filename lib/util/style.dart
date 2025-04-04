import 'package:flutter/material.dart';

class Style {
  getTTFInputDecoration({
    String? hintText,
    Widget? icon,
  }) {
    return InputDecoration(
      label: Text(hintText ?? ""),
      filled: true,
      prefixIcon: icon,
      alignLabelWithHint: true,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        borderSide: BorderSide.none,
      ),
    );
  }
}
