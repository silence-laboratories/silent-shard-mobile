// Copyright (c) Silence Laboratories Pte. Ltd.
// This software is licensed under the Silence Laboratories License Agreement.

// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:silentshard/constants.dart';

ThemeData darkTheme = ThemeData(
  fontFamily: 'Epilogue',
  brightness: Brightness.dark,
  appBarTheme: AppBarTheme(),
  textTheme: TextTheme(
    displayLarge: TextStyle(
      color: textPrimaryColor,
      fontSize: 24,
      height: 1.6,
    ),
    displayMedium: TextStyle(
      color: textPrimaryColor,
      height: 1.6,
      fontSize: 16,
    ),
    displaySmall: TextStyle(
      color: textPrimaryColor,
      fontSize: 14,
      height: 1.6,
    ),
    headlineMedium: TextStyle(
      fontSize: 16,
      color: primaryColor2,
      height: 1.6,
    ),
    headlineSmall: TextStyle(
      fontSize: 14,
      color: primaryColor2,
      height: 1.6,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: textSecondaryColor,
      height: 1.6,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.6,
      color: textSecondaryColor,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.6,
      color: textSecondaryColor,
    ),
    labelMedium: TextStyle(
      color: textPrimaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 14,
      height: 1.6,
    ),
    labelSmall: TextStyle(
      color: textPrimaryColor,
      fontSize: 10,
    ),
  ),
  dividerColor: Color(0xFF3A4252),
  // elevatedButtonTheme: ElevatedButtonThemeData(
  //   style: ButtonStyle(
  //     padding: MaterialStatePropertyAll(EdgeInsets.all(defaultPadding * 1.5)),
  //     backgroundColor: MaterialStatePropertyAll<Color>(primaryColor),
  //     shape: MaterialStatePropertyAll(
  //       RoundedRectangleBorder(
  //         borderRadius: BorderRadius.all(Radius.circular(10)),
  //       ),
  //     ),
  //   ),
  // ),
);

// ButtonStyle primaryButtomStyle = ButtonStyle(
//   padding: MaterialStatePropertyAll(EdgeInsets.all(defaultPadding * 1.5)),
//   backgroundColor: MaterialStatePropertyAll<Color>(primaryColor),
//   shape: MaterialStatePropertyAll(
//     RoundedRectangleBorder(
//       borderRadius: BorderRadius.all(Radius.circular(10)),
//     ),
//   ),
// );

  // colorSchemeSeed: primaryColor,
  // colorScheme: const ColorScheme(
  //   background: Colors.black,
  //   brightness: Brightness.dark,
  //   primary: primaryColor,
  //   onPrimary: primaryColor,
  //   secondary: secondaryColor,
  //   onSecondary: secondaryColor,
  //   error: Colors.red,
  //   onError: Colors.red,
  //   onBackground: Colors.black,
  //   surface: Colors.black,
  //   onSurface: Colors.black,
  // ),