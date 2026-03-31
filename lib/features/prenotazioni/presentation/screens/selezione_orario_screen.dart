import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/core/providers/slot_calculator_provider.dart';

import 'package:shavette/features/barbieri/domain/entities/barbiere.dart'; 
import 'package:shavette/features/barbieri/domain/entities/slot_orario.dart'; 

import 'package:shavette/features/prenotazioni/presentation/widgets/barber_row.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/confirm_sheet.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/date_strip.dart';

// 1. IL NOTIFIER PER LA DATA
// Assicurati che StateNotifier sia importato correttamente da flutter_riverpod
class ClientSelectedDateNotifier extends StateNotifier<DateTime> {
  ClientSelectedDateNotifier() : super(_initialDate());

  static DateTime _initialDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime newDate) {
    state = newDate;
  }
}

// Usiamo 'final' senza il tipo esplicito chilometrico, così Riverpod non si arrabbia
final clientSelectedDateProvider = StateNotifierProvider.autoDispose<ClientSelectedDateNotifier, DateTime>((ref) {
  return ClientSelectedDateNotifier();
});

// 2. IL MOTORE DINAMICO
final staffSaloneProvider = StreamProvider.autoDispose<List<Barbiere>>((ref) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  // Watch dell'utente loggato
  final AsyncValue<dynamic> authState = ref.watch(authStateProvider);
  final dynamic user = authState.value;
  
  // Watch degli slot calcolati
  final List<SlotOrario> slotDinamici = ref.watch(slotCalculatorProvider);

  if (user == null) {
    return Stream<List<Barbiere>>.value(<Barbiere>[]);
  }

  // Cast esplicito dell'UID
  final String uid = user.uid as String;

  return firestore
      .collection('barbieri')
      .doc(uid) 
      .collection('staff')
      .snapshots()
      .map((QuerySnapshot<Map<String, dynamic>> staffSnapshot) {
        
    return staffSnapshot.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
      final Map<String, dynamic> data = doc.data();
      final String nomeStaff = (data['nome'] as String?) ?? 'Sconosciuto';
      
      return Barbiere(
        id: doc.id,
        nome: nomeStaff,
        avatarUrl: (data['avatarUrl'] as String?) ?? 
            'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nomeStaff)}&background=random',
        slots: slotDinamici, 
        isAlCompleto: (data['isAlCompleto'] as bool?) ?? false,
      );
    }).toList();
  });
});

// 3. LA SCHERMATA
class SelezioneOrarioScreen extends ConsumerWidget {
  const SelezioneOrarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);

    // Watch degli stati
    final BookingState bookingState = ref.watch(bookingProvider);
    final DateTime dataSelezionata = ref.watch(clientSelectedDateProvider);
    final AsyncValue<List<Barbiere>> staffAsyncValue = ref.watch(staffSaloneProvider); 

    final String? selectedSlotKey =
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
            onDaySelected: (DateTime nuovaData) {
              ref.read(clientSelectedDateProvider.notifier).setDate(nuovaData);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: staffAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stack) => Center(
                child: Text('Errore: $error', style: const TextStyle(color: Colors.red)),
              ),
              data: (List<Barbiere> staffList) {
                if (staffList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Nessun collaboratore trovato.\nAssicurati di essere loggato come Barbiere e di aver completato l\'onboarding.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  itemCount: staffList.length,
                  itemBuilder: (BuildContext context, int index) {
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