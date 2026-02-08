import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF4169E1); // Royal Blue
  static const Color darkBlue = Color(0xFF003366);
  static const Color lightBlue = Color(0xFFE6F0FF);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFFF5F5F5);
  static const Color pending = Color(0xFFFFC107);
  static const Color approved = Color(0xFF4CAF50);
  static const Color rejected = Color(0xFFF44336);
}

class ApiConstants {
  // Isticmaal 10.0.2.2 Android Emulator-ka si aad u access-gareyso localhost
  // Isticmaal localhost haddii aad ku wado Web ama Desktop
  // Haddii aad isticmaalayso Mobile dhab ah, isticmaal IP address-ka mashiinkaaga
  // static const String baseUrl = 'http://localhost:5000/api';
  static const String baseUrl = 'https://digital-citizen-system.onrender.com/api'; 
}
