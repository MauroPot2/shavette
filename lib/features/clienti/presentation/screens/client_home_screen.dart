import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Importante per la navigazione
import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/core/providers/booking_provider.dart'; // Per listaSaloniProvider e selectedSaloneProvider

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;
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
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEZIONE 1: I TUOI APPUNTAMENTI ---
            Text(
              'I tuoi appuntamenti',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAppointmentsList(user?.uid),

            const SizedBox(height: 32),

            // --- SEZIONE 2: SCEGLI UN SALONE ---
            Text(
              'Prenota un servizio',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            saloniAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Errore caricamento saloni: $err')),
              data: (listaSaloni) {
                if (listaSaloni.isEmpty) {
                  return const Text('Nessun salone disponibile.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listaSaloni.length,
                  itemBuilder: (context, index) {
                    final salone = listaSaloni[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: const Icon(Icons.storefront),
                        ),
                        title: Text(
                          (salone['nome'] as String?) ?? 'Salone',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text('Tocca per vedere i barbieri'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // Uniamo i puntini: settiamo il salone scelto e navighiamo
                          final String idSalone = salone['id'] as String;
                          ref.read(selectedSaloneProvider.notifier).state =
                              idSalone;
                          ref
                              .read(bookingProvider.notifier)
                              .setSalone(idSalone);
                          context.push('/prenota-orario');
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

  // Il tuo metodo per le prenotazioni (leggermente pulito per consistenza)
  Widget _buildAppointmentsList(String? userId) {
    if (userId == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('prenotazioni')
          .where('clienteId', isEqualTo: userId)
          .orderBy('data', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: const Center(
              child: Text('Nessuna prenotazione attiva.'),
            ),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final DateTime dataApp = (data['data'] as Timestamp).toDate();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
              child: ListTile(
                title: Text(
                  DateFormat('EEEE d MMMM', 'it_IT').format(dataApp),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Ore ${data['orario']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Attivo',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
