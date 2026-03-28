import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/prenotazioni/data/mock_barbieri.dart';
import 'package:shavette/features/servizi/data/mock_servizi.dart';

class RiepilogoPrenotazioneScreen extends ConsumerWidget {
  const RiepilogoPrenotazioneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(bookingProvider);

    /// Misura di sicurezza: se per qualche motivo arriviamo qui senza dati,
    ///  mostriamo un errore
    if (bookingState.barbiereId == null ||
        bookingState.orario == null ||
        bookingState.serviziIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Errore')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Torna alla Home'),
          ),
        ),
      );
    }

    // 1. Recuperiamo i dati reali incrociando lo stato con i nostri mock
    final barbiere = barbieriDelGiorno.firstWhere(
      (b) => b.id == bookingState.barbiereId,
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
            // --- SEZIONE 1: QUANDO E CON CHI ---
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
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
                            Text(
                              'Oggi',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              bookingState.orario!,
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
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

            const SizedBox(height: 32),

            // --- SEZIONE 2: I SERVIZI (LO SCONTRINO) ---
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
                          Text(s.nome, style: const TextStyle(fontSize: 16)),
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

      // --- IL BOTTONE FINALE ---
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
              // Qui in futuro chiameremo le API per salvare nel Database (FASE 4)
              // Per ora, puliamo lo stato e torniamo alla Home con un messaggio di successo

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prenotazione confermata con successo! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );

              // Resetta il Riverpod per la prossima prenotazione
              ref.read(bookingProvider.notifier).reset();

              // Torna alla Dashboard radendo al suolo lo stack di navigazione
              context.go('/barber');
            },
            child: const Text(
              'Conferma Prenotazione',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
