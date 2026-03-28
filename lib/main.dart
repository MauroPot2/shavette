import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/router/app_router.dart';
import 'package:shavette/core/theme/app_theme.dart';
import 'package:shavette/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: ShavetteApp(),
    ),
  );
}

///classe main dell'app
class ShavetteApp extends StatelessWidget {
  ///costruttore della classe main.
  const ShavetteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shavette',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(brandColor: const Color(0xFF1E3A8A)),

      /// Usiamo il router qui.
      routerConfig: appRouter,
    );
  }
}
