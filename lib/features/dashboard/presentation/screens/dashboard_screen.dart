import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:shavette/features/auth/data/auth_repository.dart';

// 1. IL CERVELLO DELLA DATA: Ricorda quale giorno ha selezionato il barbiere.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// 2. IL MOTORE DI RICERCA: Legge le prenotazioni reali dal Database
final appuntamentiSaloneProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final user = ref.watch(authStateProvider).value;
      final selectedDate = ref.watch(selectedDateProvider);

      if (user == null) return Stream.value([]);

      // Definiamo il range temporale (dalle 00:00 alle 23:59 del giorno scelto)
      final inizioGiorno = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      final fineGiorno = inizioGiorno.add(const Duration(days: 1));

      return FirebaseFirestore.instance
          .collection('prenotazioni')
          .where(
            'saloneId',
            isEqualTo: user.uid,
          ) // Mostra solo i MIEI appuntamenti
          .where(
            'data',
            isGreaterThanOrEqualTo: Timestamp.fromDate(inizioGiorno),
          )
          .where('data', isLessThan: Timestamp.fromDate(fineGiorno))
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
    });

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedDate = ref.watch(selectedDateProvider);
    final appuntamentiAsync = ref.watch(appuntamentiSaloneProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomHeader(context, selectedDate, ref),
            const SizedBox(height: 24),
            _buildDateSelector(context, ref, selectedDate),
            const SizedBox(height: 24),

            Expanded(
              child: appuntamentiAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Errore: $err')),
                data: (appuntamenti) {
                  if (appuntamenti.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  // Ordiniamo per orario (9:00, 9:15, ecc)
                  appuntamenti.sort(
                    (a, b) => (a['orario'] as String).compareTo(
                      b['orario'] as String,
                    ),
                  );

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: appuntamenti.length,
                    itemBuilder: (context, index) {
                      final app = appuntamenti[index];
                      return _buildAppuntamentoCard(context, app);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/prenota-orario'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Appuntamento'),
      ),
    );
  }

  Widget _buildCustomHeader(
    BuildContext context,
    DateTime selectedDate,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    const mesi = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];
    final dataFormattata =
        '${selectedDate.day} ${mesi[selectedDate.month - 1]} ${selectedDate.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dataFormattata,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Agenda',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    final theme = Theme.of(context);
    const giorniSettimana = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final oggi = DateTime.now();
    final dateGenerate = List.generate(
      14,
      (i) => DateTime(oggi.year, oggi.month, oggi.day).add(Duration(days: i)),
    );

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dateGenerate.length,
        itemBuilder: (context, index) {
          final data = dateGenerate[index];
          final isSelected = data.isAtSameMomentAs(selectedDate);
          final nomeGiorno = giorniSettimana[data.weekday - 1];

          return GestureDetector(
            onTap: () => ref.read(selectedDateProvider.notifier).state = data,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 65,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: isSelected
                    ? null
                    : Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nomeGiorno,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    data.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nessun appuntamento in programma',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAppuntamentoCard(
    BuildContext context,
    Map<String, dynamic> app,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                app['orario'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Appuntamento Cliente',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Durata: ${app['durataTotale']} min',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              '${app['prezzoTotale']}€',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
