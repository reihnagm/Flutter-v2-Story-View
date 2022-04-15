import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:story_view_app/utils/box_shadow.dart';
import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/basewidgets/button/bounce.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final String btnTxt;
  final double height;
  final Color loadingColor;
  final Color btnColor;
  final Color btnTextColor;
  final Color btnBorderColor;
  final bool isBorder;
  final bool isLoading;
  final bool isBoxShadow;

  const CustomButton({
    Key? key, 
    required this.onTap, 
    required this.btnTxt, 
    this.height = 45.0,
    this.isLoading = false,
    this.loadingColor = ColorResources.white,
    this.btnColor = const Color.fromRGBO(51, 49, 68, 1.0),
    this.btnTextColor = ColorResources.white,
    this.btnBorderColor = Colors.transparent,
    this.isBorder = false,
    this.isBoxShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Bouncing(
      onPress: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: isBoxShadow 
          ? boxShadow 
          : [],
          color: btnColor,
          border: Border.all(
            color: isBorder 
            ? btnBorderColor 
            : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10.0)
        ),
        child: isLoading 
        ? Center(
            child: SpinKitFadingCircle(
              color: loadingColor,
              size: 25.0
            ),
          )
        : Center(
          child: Text(btnTxt,
            style: openSans.copyWith(
              color: btnTextColor,
              fontSize: Dimensions.fontSizeExtraSmall,
            )
          ),
        )
      ),
    );
  }
}
