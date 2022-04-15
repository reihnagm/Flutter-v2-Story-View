import 'package:flutter/material.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final Function (String) onSaved;
  final Function (String) onChanged;
  final String? regex;
  final String hintText;
  final Widget label;
  final TextInputType keyboardType;
  final bool obscureText;
  final Icon prefixIcon;
  final Color fillColor;

  const CustomTextFormField({
    Key? key, 
    this.controller,
    required this.onSaved,
    required this.onChanged,
    this.regex = "",
    required this.hintText,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.prefixIcon,
    this.fillColor = ColorResources.white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: (val) => onChanged(val),
      onSaved: (val) => onSaved(val!),
      cursorColor: ColorResources.hintColor,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: openSans.copyWith(
        letterSpacing: 1.3,
        color: ColorResources.textBlackPrimary,
        fontSize: Dimensions.fontSizeExtraSmall
      ),
      obscureText: obscureText,
      validator: (val) {
        return RegExp(regex!).hasMatch(val!) ? null : 'Enter a valid value.';
      },
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        label: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        fillColor: fillColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none
        ),
        hintText: hintText,
        hintStyle: openSans.copyWith(
          color: ColorResources.hintColor,
          fontSize: Dimensions.fontSizeSmall
        )
      ),
    );
  }
}