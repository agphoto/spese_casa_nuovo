import 'package:flutter/material.dart';

// ---------------------------------
// Colors
// ---------------------------------

extension CustomColorScheme on ColorScheme {
  Color get success => const Color(0xFF28a745);
  Color get info => const Color(0xFF17a2b8);
  Color get warning => const Color(0xFFffc107);
  Color get danger => const Color(0xFFdc3545);
}

// ---------------------------------
// TextTheme
// ---------------------------------

extension CustomTextTheme on TextTheme {
  TextStyle get italicTitle =>
      const TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic);

  TextStyle get tagBody => TextStyle(
      fontSize: 12.0, fontStyle: FontStyle.italic, color: Colors.grey[100]);

  TextStyle get italicBody =>
      const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic);

  TextStyle get boldBody =>
      const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);

  TextStyle get appBarSubTitle =>
      const TextStyle(fontSize: 11.0, fontStyle: FontStyle.italic);

  TextStyle get amountText => const TextStyle(
        fontSize: 20.0,
      );

  TextStyle get dateSmall =>
      const TextStyle(fontSize: 10.0, fontStyle: FontStyle.italic);

  TextStyle get dropDownLabelForm => TextStyle(
        fontSize: 18.0,
        color: Colors.grey[200],
      );
}
