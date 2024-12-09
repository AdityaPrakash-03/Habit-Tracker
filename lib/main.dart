// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:habbit_tracker/habbit_database/HabitDatabase.dart';
import 'package:habbit_tracker/pages/home_page.dart';
// ignore: unused_import
import 'package:habbit_tracker/theme/light.dart';
import 'package:habbit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize database
  await HabitDatabase.initialize();
  //save first launch date
  await HabitDatabase().saveFirstLaunchDate();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => HabitDatabase()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).getTheme(),
    );
  }
}
