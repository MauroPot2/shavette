import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/auth/data/auth_repository.dart'; // Per sapere chi è l'utente
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart'; // Per lo staffSaloneProvider
import 'package:shavette/features/servizi/data/mock_servizi.dart';
import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';

class RiepilogoPrenotazioneScreen extends ConsumerWidget {
  const RiepilogoPrenotazioneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(bookingProvider);

    // 1. RECUPERIAMO I DATI REALI DA FIREBASE
    final staffAsync = ref.watch(staffSaloneProvider);
    final authState = ref.watch(authStateProvider);

    // 2. MISURA DI SICUREZZA: Se mancano dati essenziali nello stato
    if (bookingState.barbiereId == null ||
        bookingState.orario == null ||
        bookingState.serviziIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Errore')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Dati mancanti. Torna alla Home'),
          ),
        ),
      );
    }

    return staffAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Errore: $err'))),
      data: (listaBarbieri) {
        // 3. TROVIAMO IL BARBIERE REALE
        final Barbiere barbiere = listaBarbieri.firstWhere(
          (b) => b.id == bookingState.barbiereId,
          orElse: () => listaBarbieri.first,
        );

        final serviziScelti = listaServizi
            .where((s) => bookingState.serviziIds.contains(s.id))
            .toList();

        final totalePrezzo = serviziScelti.fold<double>(
          0,
          (sum, item) => sum + item.prezzo,
        );

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Riepilogo',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            centerTitle: true,
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Il tuo appuntamento',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(barbiere.avatarUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              barbiere.nome,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                const Text('Oggi'),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(bookingState.orario!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Servizi selezionati',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      ...serviziScelti.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.nome,
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${s.prezzo.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Totale',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${totalePrezzo.toStringAsFixed(2)}€',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: () {
                  // TODO: FASE 4 - Salvare la prenotazione su Firestore

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prenotazione confermata con successo! 🎉'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  ref.read(bookingProvider.notifier).reset();

                  // Ritorno dinamico: se sono barbiere vado in dashboard, se cliente alla home cliente
                  // (Per ora usiamo il fallback '/dash_cliente' se non siamo sicuri)
                  context.go('/dash_cliente');
                },
                child: const Text(
                  'Conferma Prenotazione',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
