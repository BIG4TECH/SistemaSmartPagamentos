import 'package:flutter/material.dart';

Widget textFormField(controller, label, keyboardType, validator) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
    ),
    keyboardType: keyboardType,
    validator: validator
  );
}
