import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/auth/data/auth_repository.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // 1. Ascoltiamo la lista dei saloni da Firebase
    final saloniAsync = ref.watch(listaSaloniProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Shavette',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scegli il tuo salone',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Trova il barbiere perfetto per il tuo prossimo taglio'),
            const SizedBox(height: 24),

            // 2. GESTIONE DELLO STATO ASINCRONO (Firebase)
            saloniAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Errore: $err')),
              data: (listaSaloni) {
                if (listaSaloni.isEmpty) {
                  return const Center(
                    child: Text('Nessun salone disponibile al momento.'),
                  );
                }

                return ListView.builder(
                  shrinkWrap:
                      true, // Importante dentro una SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaSaloni.length,
                  itemBuilder: (context, index) {
                    final salone = listaSaloni[index];
                    final String nome =
                        (salone['nome'] as String?) ?? 'Salone senza nome';
                    final String id = salone['id'] as String;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.store,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: const Text('Taglio, Barba, Trattamenti'),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.primary,
                        ),
                        onTap: () async {
                          final String idSalone = salone['id'] as String;
                          // 3. UNIAMO I PUNTINI: Settiamo il salone e andiamo avanti
                          ref.read(selectedSaloneProvider.notifier).state =
                              idSalone;
                          ref
                              .read(bookingProvider.notifier)
                              .setSalone(idSalone);

                          await context.push('/prenota-orario');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
