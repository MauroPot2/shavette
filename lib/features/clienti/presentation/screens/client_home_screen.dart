import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shavette/features/auth/data/auth_repository.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Shavette', style: TextStyle(fontWeight: FontWeight.w900)),
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
            // 1. SALUTO PERSONALIZZATO
            Text(
              'Ciao, ${user?.displayName ?? "Cliente"}! 👋',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text('Dove vuoi farti bello oggi?'),
            
            const SizedBox(height: 24),

            // 2. BANNER PRENOTAZIONE RAPIDA
            _buildQuickActionCard(context, theme),

            const SizedBox(height: 32),

            // 3. SEZIONE PROSSIMI APPUNTAMENTI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'I tuoi appuntamenti',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('Vedi tutti')),
              ],
            ),
            const SizedBox(height: 8),

            // 4. LISTA REALE DA FIREBASE
            _buildAppointmentsList(user?.uid),
          ],
        ),
      ),
    );
  }

  // Widget per il tasto "Prenota"
  Widget _buildQuickActionCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hai bisogno di un taglio?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => context.push('/prenota-orario'),
            child: const Text('Prenota Ora'),
          ),
        ],
      ),
    );
  }

  // Widget che legge le prenotazioni da Firestore
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
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Text('Nessun appuntamento in programma.')),
          );
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final DateTime dataApp = (data['data'] as Timestamp).toDate();
            
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(
                  DateFormat('EEEE d MMMM', 'it_IT').format(dataApp),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Ore ${data['orario']} - ${data['stato']}'),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}