import 'package:flutter/material.dart';
import 'package:shavette/core/theme/app_theme.dart';

void main() {
  runApp(const ShavetteApp());
}

class ShavetteApp extends StatelessWidget {
  const ShavetteApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Simuliamo che il barbiere "Mario" abbia scelto
    ///  un Blu Scuro ed elegante come suo colore
    const coloreBrandBarbiere = Color.fromARGB(255, 211, 87, 4); 

    return MaterialApp(
      title: 'Shavette',
      debugShowCheckedModeBanner: false, /// Togliamo la fastidiosa
      ///fascetta rossa in alto a destra
      
      // INIETTIAMO IL NOSTRO DESIGN SYSTEM
      theme: AppTheme.getTheme(brandColor: const Color.fromARGB(255, 215, 31, 25)),
      
      // Schermata temporanea per vedere se il tema funziona
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Design System Test'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Il Cervello è pronto. Il Corpo sta nascendo.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Bottone White-Label'),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Inserisci il nome',
                    hintText: 'Mario Rossi',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
