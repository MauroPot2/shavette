import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod: Import aggiunto
// Riverpod: Assicurati che il percorso del provider sia corretto
import 'package:shavette/core/providers/booking_provider.dart'; 

// --- 1. MODELLI DATI ---
class MockSlot {
  final String orario;
  final bool isOccupato;
  MockSlot(this.orario, {this.isOccupato = false});
}

class MockBarbiere {
  final String id;
  final String nome;
  final String avatarUrl;
  final List<MockSlot> slots;
  final bool isAlCompleto;

  MockBarbiere({
    required this.id,
    required this.nome,
    required this.avatarUrl,
    required this.slots,
    this.isAlCompleto = false,
  });
}

// --- 2. LA LISTA DATI ---
final List<MockBarbiere> barbieriDelGiorno = [
  MockBarbiere(
    id: '1',
    nome: 'Barber Gio\'',
    avatarUrl: 'https://i.pravatar.cc/150?u=1',
    slots: [
      MockSlot('09:00'),
      MockSlot('09:30', isOccupato: true),
      MockSlot('10:00'),
      MockSlot('10:30'),
      MockSlot('11:00'),
    ],
  ),
  MockBarbiere(
    id: '2',
    nome: 'Barber Beps',
    avatarUrl: 'https://i.pravatar.cc/150?u=2',
    isAlCompleto: true,
    slots: [],
  ),
  MockBarbiere(
    id: '3',
    nome: 'Barber Marco',
    avatarUrl: 'https://i.pravatar.cc/150?u=3',
    slots: [
      MockSlot('15:00'),
      MockSlot('15:30'),
      MockSlot('16:00'),
      MockSlot('16:30'),
    ],
  ),
];

// --- 3. LA SCHERMATA ---
// Riverpod: Trasformata in ConsumerStatefulWidget
class SelezioneOrarioScreen extends ConsumerStatefulWidget {
  const SelezioneOrarioScreen({super.key});

  @override
  ConsumerState<SelezioneOrarioScreen> createState() => _SelezioneOrarioScreenState();
}

// Riverpod: Trasformata in ConsumerState
class _SelezioneOrarioScreenState extends ConsumerState<SelezioneOrarioScreen> {
  // Lasciamo locale solo il giorno, perché serve solo per l'interfaccia visiva
  int _giornoSelezionatoIndex = 0;
  
  // Riverpod: ELIMINATO _selectedSlotKey (La memoria locale non serve più)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Riverpod: Ascoltiamo il provider per capire se abbiamo già scelto un orario!
    final bookingState = ref.watch(bookingProvider);
    
    // Ricostruiamo la chiave visiva leggendo dal "Cervello"
    final selectedSlotKey = (bookingState.barbiereId != null && bookingState.orario != null) 
        ? "${bookingState.barbiereId}-${bookingState.orario}" 
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text(
          'Scegli Orario',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          _buildDateStrip(theme),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              itemCount: barbieriDelGiorno.length,
              itemBuilder: (context, index) {
                // Passiamo la chiave globale alla funzione che disegna il barbiere
                return _buildBarberRow(theme, barbieriDelGiorno[index], selectedSlotKey);
              },
            ),
          ),
        ],
      ),
      bottomSheet: _buildConfirmSheet(theme, bookingState.barbiereId, bookingState.orario),
    );
  }

  Widget _buildDateStrip(ThemeData theme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final data = DateTime.now().add(Duration(days: index));
          final isSelected = _giornoSelezionatoIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _giornoSelezionatoIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .3,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getGiornoSettimana(data.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.day.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
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

  // Aggiunto selectedSlotKey globale come parametro
  Widget _buildBarberRow(ThemeData theme, MockBarbiere barbiere, String? selectedSlotKey) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: .2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(barbiere.avatarUrl),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      barbiere.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      barbiere.isAlCompleto
                          ? 'Nessun posto oggi'
                          : 'Posti disponibili',
                      style: TextStyle(
                        fontSize: 12,
                        color: barbiere.isAlCompleto
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!barbiere.isAlCompleto)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: barbiere.slots.length,
              itemBuilder: (context, index) {
                final slot = barbiere.slots[index];
                final key = "${barbiere.id}-${slot.orario}";
                final isSelected = selectedSlotKey == key; // Verifica dallo stato globale

                return GestureDetector(
                  onTap: slot.isOccupato
                      ? null
                      // Riverpod: QUANDO TAPPIAMO, SCRIVIAMO NEL CERVELLO!
                      : () => ref.read(bookingProvider.notifier).setOrario(barbiere.id, slot.orario),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : (slot.isOccupato
                                ? Colors.transparent
                                : theme.colorScheme.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot.orario,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (slot.isOccupato
                                    ? Colors.grey[400]
                                    : theme.colorScheme.onSurface),
                          decoration: slot.isOccupato
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, size: 18),
              label: const Text('Avvisami se si libera un posto'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: .5)),
      ],
    );
  }

  // Riceve i dati direttamente dal provider letto nel metodo build
  Widget _buildConfirmSheet(ThemeData theme, String? barbiereId, String? orario) {
    if (barbiereId == null || orario == null) return const SizedBox.shrink();
    
    // Troviamo il barbiere per passarlo alla prossima schermata
    final barbiere = barbieriDelGiorno.firstWhere((b) => b.id == barbiereId);
    const minutiLiberi = 45;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () {
          // Riverpod + GoRouter: Usiamo i dati letti dal Provider per navigare
          context.push('/menu-servizi/${barbiere.nome}/$orario/$minutiLiberi');
        },
        child: const Text(
          'Conferma Orario',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getGiornoSettimana(int weekday) {
    const giorni = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    return giorni[weekday - 1];
  }
}
