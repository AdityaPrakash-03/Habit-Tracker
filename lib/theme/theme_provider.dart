import 'package:flutter/material.dart';
import 'package:habbit_tracker/theme/light.dart';
import 'package:habbit_tracker/theme/dark.dart';

class ThemeProvider extends ChangeNotifier {
  // initialize with lightTheme instead of ThemeData.light()
  ThemeData themeData = lightTheme;

  // check if dark mode
  bool get isDarkMode => themeData == darkTheme;

  //get current theme
  ThemeData getTheme() => themeData;

  //set theme
  void setTheme(ThemeData theme) {
    themeData = theme;
    notifyListeners();
  }

  //toggle theme
  void toggleTheme() {
    if(themeData == lightTheme) {
      themeData = darkTheme;
    } else {
      themeData = lightTheme;
    }
    notifyListeners();
  }
}

