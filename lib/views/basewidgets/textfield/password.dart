
import 'package:flutter/material.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

class CustomTextPasswordFormField extends StatefulWidget {
  final TextEditingController? controller;
  final Function (String) onSaved;
  final String regex;
  final String hintText;
  final Widget label;
  final Color? fillColor;

  const CustomTextPasswordFormField({
    Key? key, 
    this.controller,
    required this.onSaved,
    required this.regex,
    required this.hintText,
    required this.label,
    this.fillColor = ColorResources.white
  }) : super(key: key);

  @override
  State<CustomTextPasswordFormField> createState() => _CustomTextPasswordFormFieldState();
}

class _CustomTextPasswordFormFieldState extends State<CustomTextPasswordFormField> {
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onSaved: (val) => widget.onSaved(val!),
      cursorColor: ColorResources.hintColor,
      style: openSans.copyWith(
        letterSpacing: 1.3,
        color: ColorResources.textBlackPrimary,
        fontSize: Dimensions.fontSizeExtraSmall
      ),
      obscureText: obscureText,
      validator: (val) {
        return RegExp(widget.regex).hasMatch(val!) ? null : 'Enter a valid value.';
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock,
          size: 20.0,  
          color: ColorResources.backgroundBlackPrimary,
        ),
        fillColor: widget.fillColor,
        filled: true,
        suffixIcon: InkWell(
          onTap: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
          child: Icon(
            obscureText 
            ? Icons.visibility_off
            : Icons.visibility,
            size: 20.0,  
            color: ColorResources.backgroundBlackPrimary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        label: widget.label,
        hintText: widget.hintText,
        hintStyle: openSans.copyWith(
          color: ColorResources.hintColor,
          fontSize: Dimensions.fontSizeSmall
        )
      ),
    );
  }
}