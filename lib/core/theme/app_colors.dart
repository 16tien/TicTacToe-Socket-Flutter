import 'package:flutter/material.dart';

class AppColors {
  static Color background(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.white : Colors.black;

  // Text chính
  static Color text(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white;

  // Icon, hint text
  static Color icon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white54;

  // Nền search bar, card, input
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.grey[200]! : Colors.grey[900]!;

  // Viền / divider
  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light ? Colors.grey[300]! : Colors.grey[700]!;
}
