import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shavette/core/providers/slot_calculator_provider.dart';
import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';

/// 1. IL TELECOMANDO: Tiene in memoria l'ID del salone che il cliente ha cliccato.
/// Viene aggiornato nella ClientHomeScreen tramite ref.read(selectedSaloneProvider.notifier).state = id;
final selectedSaloneProvider = StateProvider<String?>((ref) => null);

/// 2. IL MOTORE DI RICERCA: Recupera i barbieri (staff) del salone selezionato.
/// Si aggiorna automaticamente ogni volta che il selectedSaloneProvider cambia.
final staffSaloneProvider = StreamProvider.autoDispose<List<Barbiere>>((ref) {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Ascoltiamo quale salone è stato scelto
  final String? saloneSceltoId = ref.watch(selectedSaloneProvider);

  // Se non c'è ancora un salone scelto (es. all'avvio), restituiamo una lista vuota
  if (saloneSceltoId == null) {
    return Stream.value(<Barbiere>[]);
  }

  // Puntiamo alla sotto-collezione 'staff' dentro il documento del salone scelto
  return firestore
      .collection('barbieri')
      .doc(saloneSceltoId)
      .collection('staff')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final String nomeStaff = (data['nome'] as String?) ?? 'Barbiere';

          // Trasformiamo il documento Firestore nell'oggetto Barbiere usato dalla UI
          return Barbiere(
            id: doc.id,
            nome: nomeStaff,
            avatarUrl:
                (data['avatarUrl'] as String?) ??
                'https://ui-avatars.com/api/?name=${Uri.encodeComponent(nomeStaff)}&background=random',
            // Colleghiamo il calcolatore dinamico degli slot orari
            slots: ref.watch(slotCalculatorProvider),
            isAlCompleto: (data['isAlCompleto'] as bool?) ?? false,
          );
        }).toList();
      });
});

/// 3. LA LISTA DEI SALONI: Recupera tutti i saloni disponibili per la Home Cliente.
final listaSaloniProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('barbieri')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map(
              (doc) => {
                'id': doc.id,
                ...doc.data(),
              },
            )
            .toList(),
      );
});
