import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/features/barbieri/data/barbieri_repository.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/data/mock_servizi.dart';
import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';

class RiepilogoPrenotazioneScreen extends ConsumerWidget {
  const RiepilogoPrenotazioneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(bookingProvider);

    // Recuperiamo i dati necessari dai provider
    final staffAsync = ref.watch(staffSaloneProvider);
    final dataSelezionata = ref.watch(clientSelectedDateProvider);

    // 1. MISURA DI SICUREZZA: Controllo dati mancanti
    if (bookingState.barbiereId == null ||
        bookingState.orario == null ||
        bookingState.serviziIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Errore')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/dash_cliente'),
            child: const Text('Dati mancanti. Torna alla Home'),
          ),
        ),
      );
    }

    return staffAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Errore nel caricamento staff: $err')),
      ),
      data: (listaBarbieri) {
        // 2. RECUPERO BARBIERE E CALCOLO PREZZO
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

                // CARD INFO BARBIERE E DATA
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
                                Text(
                                  DateFormat(
                                    'EEEE d MMMM',
                                    'it_IT',
                                  ).format(dataSelezionata),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Ore ${bookingState.orario!}',
                                  style: const TextStyle(fontSize: 13),
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

                Text(
                  'Servizi selezionati',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // CARD LISTA SERVIZI E TOTALE
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

          // BOTTONE DI CONFERMA FINALE
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
                onPressed: () async {
                  final user = ref.read(authStateProvider).value;
                  final repository = ref.read(barbieriRepositoryProvider);

                  if (user == null) return;

                  try {
                    // Mostriamo caricamento
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    // Salvataggio su Firestore
                    await repository.salvaPrenotazione(
                      clienteId: user.uid,
                      barbiereId: bookingState.barbiereId!,
                      saloneId: user.uid, // In test usiamo l'UID corrente
                      orario: bookingState.orario!,
                      data: dataSelezionata,
                      serviziIds: bookingState.serviziIds,
                      durataTotale: bookingState.minutiTotali,
                      prezzoTotale: totalePrezzo,
                    );

                    if (context.mounted) Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prenotazione confermata! A presto! 🎉'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Reset stato e ritorno in Home
                    ref.read(bookingProvider.notifier).reset();
                    context.go('/dash_cliente');
                  } catch (e) {
                    if (context.mounted) Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Errore: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
