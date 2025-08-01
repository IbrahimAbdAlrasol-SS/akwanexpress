import 'package:flutter/material.dart';

enum ToastGravity { TOP, BOTTOM }

class GlobalToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM, // retained for compatibility
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    double fontSize = 16.0,
    int durationInSeconds = 2,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars(); // avoid stacking

    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: textColor, fontSize: fontSize),
      ),
      duration: Duration(seconds: durationInSeconds),
      backgroundColor: backgroundColor,
      behavior: gravity == ToastGravity.TOP
          ? SnackBarBehavior.floating
          : SnackBarBehavior.fixed,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess({
    required BuildContext context,
    required String message,
    ToastGravity gravity = ToastGravity.BOTTOM,
    Color backgroundColor = Colors.green,
    Color textColor = Colors.white,
    double fontSize = 16.0,
    int durationInSeconds = 2,
  }) {
    show(
      context: context,
      message: message,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: fontSize,
      durationInSeconds: durationInSeconds,
    );
  }
}
