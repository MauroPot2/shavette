import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:shavette/core/providers/booking_provider.dart';

// Importiamo le entità corrette
import 'package:shavette/features/barbieri/domain/entities/barbiere.dart'; 
import 'package:shavette/features/barbieri/domain/entities/slot_orario.dart'; // NECESSARIO PER IL LINTER

import 'package:shavette/features/prenotazioni/presentation/widgets/barber_row.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/confirm_sheet.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/date_strip.dart';

// 1. IL CERVELLO DELLA DATA (Gestito con StateNotifier)
class ClientSelectedDateNotifier extends StateNotifier<DateTime> {
  ClientSelectedDateNotifier() : super(_initialDate());

  static DateTime _initialDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime newDate) {
    state = newDate;
  }
}

final clientSelectedDateProvider = 
    StateNotifierProvider.autoDispose<ClientSelectedDateNotifier, DateTime>(
  (ref) => ClientSelectedDateNotifier(),
);

// 2. IL NUOVO MOTORE: Legge esattamente dalla struttura del tuo Repository!
final staffSaloneProvider = StreamProvider.autoDispose<List<Barbiere>>((ref) {
  final firestore = FirebaseFirestore.instance;

  // MVP: Andiamo a pescare il primissimo salone che trova nel DB
  return firestore.collection('barbieri').limit(1).snapshots().asyncMap((saloneSnapshot) async {
    if (saloneSnapshot.docs.isEmpty) return []; 
    
    final saloneId = saloneSnapshot.docs.first.id;

    // Entriamo nella sotto-collezione 'staff' creata dal tuo batch.set!
    final staffSnapshot = await firestore
        .collection('barbieri')
        .doc(saloneId)
        .collection('staff')
        .get();

    // Trasformiamo i documenti Firebase in oggetti "Barbiere" (Collaboratori)
    return staffSnapshot.docs.map((doc) {
      final data = doc.data();
      final nomeStaff = (data['nome'] as String?) ?? 'Sconosciuto';
      
      return Barbiere(
        id: doc.id,
        nome: nomeStaff,
        // Avatar provvisorio visto che non lo carichiamo ancora nell'onboarding
        avatarUrl: (data['avatarUrl'] as String?) ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nomeStaff)}&background=random',
        
        // Specifichiamo <SlotOrario> per far felice il linter!
        slots: <SlotOrario>[], 
        
        // Di default il collaboratore non è al completo finché non calcoliamo gli appuntamenti
        isAlCompleto: false,
      );
    }).toList();
  });
});

// 3. LA SCHERMATA
class SelezioneOrarioScreen extends ConsumerWidget {
  const SelezioneOrarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final bookingState = ref.watch(bookingProvider);
    final dataSelezionata = ref.watch(clientSelectedDateProvider);
    final staffAsyncValue = ref.watch(staffSaloneProvider); 

    final selectedSlotKey =
        (bookingState.barbiereId != null && bookingState.orario != null)
        ? '${bookingState.barbiereId}-${bookingState.orario}'
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
          DateStrip(
            selectedDate: dataSelezionata,
            onDaySelected: (nuovaData) {
              ref.read(clientSelectedDateProvider.notifier).setDate(nuovaData);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: staffAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              
              error: (error, stack) => Center(
                child: Text('Errore: $error', style: const TextStyle(color: Colors.red)),
              ),
              
              data: (staffList) {
                if (staffList.isEmpty) {
                  return const Center(child: Text('Nessun collaboratore trovato.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    return BarberRow(
                      barbiere: staffList[index],
                      selectedSlotKey: selectedSlotKey,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: ConfirmSheet(
        barbiereId: bookingState.barbiereId,
        orario: bookingState.orario,
      ),
    );
  }
}