import 'package:flutter/material.dart';

class AppTheme {
  // Colores oficiales Banco Pichincha Perú
  static const Color amarillo = Color(0xFFFFD100);
  static const Color navy = Color(0xFF1A2B5E);
  static const Color navyOscuro = Color(0xFF0F1A3D);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color grisMedio = Color(0xFF9E9E9E);
  static const Color verdeSaldo = Color(0xFF2E7D32);
  static const Color rojoError = Color(0xFFC62828);

  static ThemeData get temaCliente => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: amarillo,
          surface: blanco,
          error: rojoError,
        ),
        scaffoldBackgroundColor: grisClaro,
        appBarTheme: const AppBarTheme(
          backgroundColor: navy,
          foregroundColor: blanco,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: amarillo,
            foregroundColor: navy,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: blanco,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: grisMedio),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: grisMedio.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: navy, width: 2),
          ),
          labelStyle: const TextStyle(color: grisMedio),
          prefixIconColor: navy,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: blanco,
          selectedItemColor: navy,
          unselectedItemColor: grisMedio,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );
}