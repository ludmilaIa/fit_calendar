import 'package:flutter/material.dart';
import 'signin.dart';
import 'common/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fit Calendar',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.softBlack,
        primaryColor: AppColors.primaryBlue,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primaryBlue,
          secondary: AppColors.neonBlue,
        ),
      ),
      home: const SignInView(),
    );
  }
}
