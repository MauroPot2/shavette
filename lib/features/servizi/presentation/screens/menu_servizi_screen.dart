import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/utils/time_utils.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/core/providers/booking_provider.dart';

// --- MODELLO SERVIZIO ---
class Servizio {
  final String id;
  final String nome;
  final int durataMinuti;
  final double prezzo;
  final String categoria;

  const Servizio({
    required this.id,
    required this.nome,
    required this.durataMinuti,
    required this.prezzo,
    required this.categoria,
  });
}

// --- DATI DI ESEMPIO ---
const List<Servizio> listaServizi = [
  Servizio(
    id: '1',
    nome: 'Taglio Gentleman',
    durataMinuti: 30,
    prezzo: 25.0,
    categoria: 'Capelli',
  ),
  Servizio(
    id: '2',
    nome: 'Taglio + Barba Relax',
    durataMinuti: 60,
    prezzo: 45.0,
    categoria: 'Combo',
  ),
  Servizio(
    id: '3',
    nome: 'Regolazione Barba',
    durataMinuti: 20,
    prezzo: 15.0,
    categoria: 'Barba',
  ),
  Servizio(
    id: '4',
    nome: 'Trattamento Viso Hot Towel',
    durataMinuti: 15,
    prezzo: 10.0,
    categoria: 'Special',
  ),
];

class MenuServiziScreen extends ConsumerStatefulWidget {
  final String nomeBarbiere;
  final int minutiDisponibili;
  final String orarioSelezionato;

  const MenuServiziScreen({
    super.key,
    required this.nomeBarbiere,
    this.minutiDisponibili = 40,
    this.orarioSelezionato = '10:00',
  });

  @override
  ConsumerState<MenuServiziScreen> createState() => _MenuServiziScreenState();
}

class _MenuServiziScreenState extends ConsumerState<MenuServiziScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Leggiamo lo stato globale in tempo reale
    final bookingState = ref.watch(bookingProvider);
    final serviziSelezionatiIds = bookingState.serviziIds;

    // Calcolo minuti reali dal Cervello
    final minutiLiberiReali = _calcolaMinutiLiberiReali(
      bookingState.barbiereId,
      bookingState.orario,
    );

    // Calcolo totali dinamici
    final selezionati = listaServizi
        .where((s) => serviziSelezionatiIds.contains(s.id))
        .toList();

    final totaleTempo = bookingState.minutiTotali;

    final totalePrezzo = selezionati.fold<double>(
      0,
      (sum, item) => sum + item.prezzo,
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Seleziona Servizi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          // PASSIAMO i minuti calcolati al banner
          _buildInfoBanner(theme, minutiLiberiReali),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: listaServizi.length,
              itemBuilder: (context, index) {
                final servizio = listaServizi[index];
                final isSelected = serviziSelezionatiIds.contains(servizio.id);
                final bool fitsInSlot =
                    (totaleTempo + servizio.durataMinuti) <= minutiLiberiReali;

                // PASSIAMO i minuti calcolati alla card
                return _buildServiceCard(
                  theme,
                  servizio,
                  isSelected,
                  fitsInSlot,
                  minutiLiberiReali,
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: _buildSummarySheet(theme, totalePrezzo, totaleTempo),
    );
  }

  // Riceve i minuti in ingresso
  Widget _buildInfoBanner(ThemeData theme, int minutiLiberiReali) {
    final bookingState = ref.watch(bookingProvider);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Prenotazione con ${widget.nomeBarbiere} alle ${bookingState.orario ?? widget.orarioSelezionato}.\nSpazio libero: $minutiLiberiReali min.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Riceve i minuti in ingresso
  Widget _buildServiceCard(
    ThemeData theme,
    Servizio servizio,
    bool isSelected,
    bool fitsInSlot,
    int minutiLiberiReali,
  ) {
    return GestureDetector(
      onTap: () {
        if (isSelected || fitsInSlot) {
          ref
              .read(bookingProvider.notifier)
              .toggleServizio(servizio.id, servizio.durataMinuti);
        } else {
          _mostraSuggerimentoSpostamento(context, servizio, minutiLiberiReali);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servizio.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${servizio.durataMinuti} min',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${servizio.prezzo.toStringAsFixed(0)}€',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!fitsInSlot && !isSelected)
              const Icon(
                Icons.history_toggle_off_rounded,
                color: Colors.orange,
                size: 20,
              )
            else
              Checkbox(
                value: isSelected,
                onChanged: (val) {
                  if (isSelected || fitsInSlot) {
                    ref
                        .read(bookingProvider.notifier)
                        .toggleServizio(servizio.id, servizio.durataMinuti);
                  } else {
                    _mostraSuggerimentoSpostamento(
                      context,
                      servizio,
                      minutiLiberiReali,
                    );
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Riceve i minuti in ingresso
  Future<void> _mostraSuggerimentoSpostamento(
    BuildContext context,
    Servizio servizio,
    int minutiLiberiReali,
  ) async {
    final theme = Theme.of(context);
    final bookingState = ref.read(bookingProvider);

    final barbiere = barbieriDelGiorno.firstWhere(
      (b) => b.id == bookingState.barbiereId,
    );

    final prossimoSlotDisponibile = TimeUtils.trovaProssimoSlotDisponibile(
      slotsDelBarbiere: barbiere.slots,
      orarioSelezionato: bookingState.orario!,
      durataServizioMinuti: servizio.durataMinuti,
    );

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              prossimoSlotDisponibile != null
                  ? Icons.auto_awesome
                  : Icons.error_outline,
              color: prossimoSlotDisponibile != null
                  ? Colors.amber
                  : Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              prossimoSlotDisponibile != null
                  ? 'Serve più tempo!'
                  : 'Giornata Piena!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            // Risolta l'interpolazione della stringa
            Text(
              prossimoSlotDisponibile != null
                  ? '''
Il servizio "${servizio.nome}" richiede ${servizio.durataMinuti} minuti, ma alle ${bookingState.orario} abbiamo solo $minutiLiberiReali minuti liberi.
                  '''
                  : '''
                  Purtroppo non ci sono buchi abbastanza grandi per "${servizio.nome}" il resto della giornata.
                  ''',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            if (prossimoSlotDisponibile != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  ref
                      .read(bookingProvider.notifier)
                      .setOrario(
                        bookingState.barbiereId!,
                        prossimoSlotDisponibile,
                      );
                  ref
                      .read(bookingProvider.notifier)
                      .toggleServizio(servizio.id, servizio.durataMinuti);
                  Navigator.pop(context);
                },
                child: Text(
                  'Sposta alle $prossimoSlotDisponibile',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Scegli un altro servizio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySheet(ThemeData theme, double prezzo, int tempo) {
    final bookingState = ref.watch(bookingProvider);
    if (bookingState.serviziIds.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Totale stimato',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '$tempo min • ${prezzo.toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Continua',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  int _calcolaMinutiLiberiReali(String? barbiereId, String? orario) {
    if (barbiereId == null || orario == null) return 0;

    final barbiere = barbieriDelGiorno.firstWhere((b) => b.id == barbiereId);
    final startIndex = barbiere.slots.indexWhere((s) => s.orario == orario);
    if (startIndex == -1) return 0;

    int slotLiberiConsecutivi = 0;
    for (int i = startIndex; i < barbiere.slots.length; i++) {
      if (barbiere.slots[i].isOccupato) break;
      slotLiberiConsecutivi++;
    }

    return slotLiberiConsecutivi * 30;
  }
}
