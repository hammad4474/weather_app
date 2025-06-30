import 'package:flutter/material.dart';

final ligthTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  colorScheme: ColorScheme.light(
    primary: Color.fromARGB(26, 255, 255, 255),
    secondary: Colors.white,
    surface: Colors.white30,
    onPrimary: Colors.white70,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  colorScheme: ColorScheme.dark(
    primary: Color.fromARGB(21, 0, 0, 0),
    secondary: Colors.black,
    surface: Colors.black38,
    onPrimary: Colors.black38,
  ),
);
