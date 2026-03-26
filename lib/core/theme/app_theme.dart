import 'package:flutter/material.dart';

class AppTheme {
  /// Questo è il generatore del tema White-Label.
  /// Passandogli il colore principale del brand del barbiere,
  /// Flutter costruirà un'intera interfaccia perfettamente bilanciata.
  static ThemeData getTheme({required Color brandColor}) {
    return ThemeData(
      useMaterial3: true,
      
      // 1. GENERATORE DELLA PALETTE COLORI
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        brightness: Brightness.light, // Per ora facciamo la versione chiara
      ),

      // 2. TIPOGRAFIA GLOBALE
      // (Impostiamo font eleganti e moderni per un gestionale)
      fontFamily: 'Roboto', // Sostituiremo con un Google Font custom in seguito
      
      // 3. STILE GLOBALE DEI BOTTONI
      // Tutti i bottoni "Elevated" dell'app avranno questo aspetto di default
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Bordi moderni leggermente arrotondati
          ),
        ),
      ),

      // 4. STILE GLOBALE DEGLI INPUT (Campi di testo)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: brandColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}