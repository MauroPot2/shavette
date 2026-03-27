import 'package:flutter/material.dart';
import 'package:shavette/core/theme/app_theme.dart';
import 'package:shavette/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart'; // Aggiungi questo import!

void main() {
  runApp(const ShavetteApp());
}

class ShavetteApp extends StatelessWidget {
  const ShavetteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coloreBrandBarbiere = Color(0xFF1E3A8A);

    return MaterialApp(
      title: 'Shavette',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(brandColor: coloreBrandBarbiere),
      home: const SelezioneOrarioScreen(), // ECCO LA MAGIA
    );
  }
}
