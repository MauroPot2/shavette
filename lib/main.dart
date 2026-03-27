import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/theme/app_theme.dart';
import 'package:shavette/features/servizi/presentation/screens/menu_servizi_screen.dart'; 

void main() {
  runApp(const ProviderScope(
    child: ShavetteApp()
    ),);
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
      home: const MenuServiziScreen(), /// Punto di ingresso App.-
    );
  }
}
