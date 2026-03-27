import 'package:flutter/material.dart';

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

class MenuServiziScreen extends StatefulWidget {
  final String nomeBarbiere;
  final int minutiDisponibili; // Tempo residuo dello slot scelto (es. 40 min)
  final String orarioSelezionato; // Es: "10:00"

  const MenuServiziScreen({
    super.key,
    required this.nomeBarbiere,
    this.minutiDisponibili =
        40, // Mock: lo slot delle 10:00 ha solo 40min liberi
    this.orarioSelezionato = '10:00',
  });

  @override
  State<MenuServiziScreen> createState() => _MenuServiziScreenState();
}

class _MenuServiziScreenState extends State<MenuServiziScreen> {
  final Set<String> _serviziSelezionatiIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calcolo totali dinamici
    final selezionati = listaServizi
        .where((s) => _serviziSelezionatiIds.contains(s.id))
        .toList();
    final totaleTempo = selezionati.fold<int>(
      0,
      (sum, item) => sum + item.durataMinuti,
    );
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
          _buildInfoBanner(theme),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: listaServizi.length,
              itemBuilder: (context, index) {
                final servizio = listaServizi[index];
                final isSelected = _serviziSelezionatiIds.contains(servizio.id);

                // Verifica compatibilità temporale
                final bool fitsInSlot =
                    (totaleTempo + servizio.durataMinuti) <=
                    widget.minutiDisponibili;

                return _buildServiceCard(
                  theme,
                  servizio,
                  isSelected,
                  fitsInSlot,
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: _buildSummarySheet(theme, totalePrezzo, totaleTempo),
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
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
              '''
              Prenotazione con ${widget.nomeBarbiere} alle ${widget.orarioSelezionato}. 
              Spazio libero: ${widget.minutiDisponibili} min.
              ''',
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

  Widget _buildServiceCard(
    ThemeData theme,
    Servizio servizio,
    bool isSelected,
    bool fitsInSlot,
  ) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          setState(() => _serviziSelezionatiIds.remove(servizio.id));
        } else if (fitsInSlot) {
          setState(() => _serviziSelezionatiIds.add(servizio.id));
        } else {
          _mostraSuggerimentoSpostamento(context, servizio);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.4)
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
                  if (isSelected) {
                    setState(() => _serviziSelezionatiIds.remove(servizio.id));
                  } else if (fitsInSlot) {
                    setState(() => _serviziSelezionatiIds.add(servizio.id));
                  } else {
                    _mostraSuggerimentoSpostamento(context, servizio);
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

  void _mostraSuggerimentoSpostamento(BuildContext context, Servizio servizio) {
    final theme = Theme.of(context);
    // Mock: in futuro il "Cervello" ci darà l'orario reale
    const prossimoSlotDisponibile = "11:30";

    showModalBottomSheet(
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
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Serve più tempo!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Text(
              'Il servizio "${servizio.nome}" richiede ${servizio.durataMinuti} minuti, ma alle ${widget.orarioSelezionato} abbiamo solo ${widget.minutiDisponibili} minuti liberi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // TODO: Logica di spostamento orario
                Navigator.pop(context);
              },
              child: const Text(
                'Sposta alle $prossimoSlotDisponibile',
                style: TextStyle(fontWeight: FontWeight.bold),
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
    if (_serviziSelezionatiIds.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, -5),
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
}
