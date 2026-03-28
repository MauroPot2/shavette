import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/router/app_router.dart';
import 'package:shavette/features/auth/data/auth_repository.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi sei?'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Benvenuto su Shavette!\nScegli come vuoi usare l\'app:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              // BOTTONE BARBIERE (B2B)
              ElevatedButton.icon(
                icon: const Icon(Icons.store),
                label: const Text('Gestisco un Salone (Barbiere)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  /// 1. Aggiorniamo il provider.
                  /// Appena questo cambia,
                  /// GoRouter se ne accorge e lancia la guardia!
                  ref.read(userRoleProvider.notifier).state = 'barber';

                  // (Più avanti, qui aggiungeremo la chiamata per salvare 'barber' su Firestore)
                },
              ),

              const SizedBox(height: 16),

              // BOTTONE CLIENTE (B2C)
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Cerco un Barbiere (Cliente)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onSecondaryContainer,
                ),
                onPressed: () {
                  // 1. Aggiorniamo il provider con il ruolo cliente.
                  ref.read(userRoleProvider.notifier).state = 'client';

                  // (Più avanti, qui salveremo 'client' su Firestore)
                },
              ),

              const Spacer(),

              // TASTO DI EMERGENZA PER IL LOGOUT DURANTE I TEST
              TextButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Esci (Test)',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  // Questo resetta il login Google e ti riporta alla LoginScreen
                  await ref.read(authRepositoryProvider).signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
