import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/router/app_router.dart';

class ShavetteApp extends ConsumerWidget {
  // <-- Diventa ConsumerWidget
  const ShavetteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leggiamo il router dinamico
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Shavette',
      theme: ThemeData(/*... il tuo tema ...*/),
      routerConfig: router, // <-- Usiamo il router appena letto
    );
  }
}
