import 'package:flutter/material.dart';

Widget textFormField(controller, label, keyboardType, validator) {
  return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
      keyboardType: keyboardType,
      validator: validator);
}

Widget loginTextFormField(
    controller, label, keyboardType, validator, onChanged) {
  return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: label,
      ),
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator);
}
