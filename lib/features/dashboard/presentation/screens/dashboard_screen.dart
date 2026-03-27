import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomHeader(context),
            const SizedBox(height: 24),

            // LA NUOVA CALENDAR STRIP PREMIUM
            _buildDateSelector(context),

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
        elevation: 4, // Leggermente più visibile
        icon: const Icon(Icons.add),
        label: const Text('Nuovo Appuntamento'),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '26 Marzo 2026', // Data reale dinamica in futuro
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

  // --- LA MAGIA DELLA TOP APP: IL SELETTORE ORIZZONTALE ---
  Widget _buildDateSelector(BuildContext context) {
    final theme = Theme.of(context);

    // Nomi dei giorni finti per l'effetto visivo
    final giorni = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab'];
    final date = [26, 27, 28, 29, 30, 31];

    return SizedBox(
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6,
        itemBuilder: (context, index) {
          // Fingiamo che il primo elemento sia "Oggi" ed è quello selezionato
          final isSelected = index == 0;

          return Container(
            width: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              // Se è selezionato si colora del brand, altrimenti è trasparente
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
                  giorni[index],
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
                  date[index].toString(),
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
          );
        },
      ),
    );
  }

  Widget _buildListaAppuntamentiFinta(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: 4,
      itemBuilder: (context, index) {
        // Simuliamo che il primo appuntamento della lista sia quello "In Corso"
        final isInCorso = index == 0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16.0),
          /// Se è in corso, diamo uno sfondo leggermente colorato
          /// col colore del brand
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Colonna Orario
                Column(
                  children: [
                    Text(
                      '10:00',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '10:45',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // Divisore verticale
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 2,
                  height: 40,
                  color: isInCorso
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),

                // Info Cliente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mario Rossi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taglio + Barba',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Azione Rapida
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
