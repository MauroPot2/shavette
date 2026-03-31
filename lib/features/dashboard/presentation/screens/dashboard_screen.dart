import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// 1. IL CERVELLO DELLA DATA: Ricorda quale giorno ha selezionato il barbiere.
// Di default parte dalla data e ora esatta di "oggi".
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  // Resettiamo ore e minuti per avere una data "pulita" (es. 26 Marzo 00:00)
  return DateTime(now.year, now.month, now.day);
});

// 2. TRASFORMIAMO IN CONSUMER WIDGET per poter ascoltare il provider
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ascoltiamo la data selezionata per aggiornare la UI dinamicamente
    final selectedDate = ref.watch(selectedDateProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomHeader(context, selectedDate),
            const SizedBox(height: 24),

            _buildDateSelector(context, ref, selectedDate),

            const SizedBox(height: 24),
            Expanded(
              child: _buildListaAppuntamentiFinta(context),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/prenota-orario');
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Appuntamento'),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, DateTime selectedDate) {
    final theme = Theme.of(context);

    // Un piccolo helper per i mesi in italiano
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
                dataFormattata, // ORA È DINAMICO!
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Appuntamenti',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(
              Icons.storefront,
              color: theme.colorScheme.onSecondaryContainer,
            ),
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

    // Mappa dei giorni in italiano
    const giorniSettimana = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

    // Generiamo i prossimi 14 giorni a partire da "oggi"
    final oggi = DateTime.now();
    final dateGenerate = List.generate(14, (index) {
      return DateTime(
        oggi.year,
        oggi.month,
        oggi.day,
      ).add(Duration(days: index));
    });

    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dateGenerate.length,
        itemBuilder: (context, index) {
          final data = dateGenerate[index];

          // Controlliamo se la data in questa "card" è quella attualmente selezionata nello stato
          final isSelected = data.isAtSameMomentAs(selectedDate);

          // data.weekday va da 1 (Lunedì) a 7 (Domenica). Sottraiamo 1 per l'indice dell'array.
          final nomeGiorno = giorniSettimana[data.weekday - 1];

          return GestureDetector(
            onTap: () {
              // Quando tocchi un giorno, aggiorniamo il Provider!
              // Tutta la schermata si ricostruirà istantaneamente.
              ref.read(selectedDateProvider.notifier).state = data;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
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
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontSize: 20,
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

  // Questo per ora rimane finto, lo collegheremo a Firebase nel prossimo step!
  Widget _buildListaAppuntamentiFinta(BuildContext context) {
    // ... (mantieni esattamente il tuo codice finto qui per ora)
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        final isInCorso = index == 0;
        return Card(
          // ... il resto della tua card
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          color: isInCorso
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: isInCorso
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Appuntamenti Mock...'), // Placeholder per abbreviare
          ),
        );
      },
    );
  }
}
