import 'package:flutter/material.dart';

class ShowSnackbar {
  ShowSnackbar._();
  static snackbar(BuildContext context, String content, String label, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          content, 
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.white
          )
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          textColor: Colors.white,
          label: label,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar()
        ),
      )
    );
  }
}