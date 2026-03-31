// ignore_for_file: public_member_api_docs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/barbieri/domain/entities/slot_orario.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';

// 1. Provider che legge le prenotazioni esistenti (lo lasciamo com'è, è corretto)
final prenotazioniGiornoProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final dataSelezionata = ref.watch(clientSelectedDateProvider);

  final inizioGiorno = DateTime(
    dataSelezionata.year,
    dataSelezionata.month,
    dataSelezionata.day,
  );
  final fineGiorno = inizioGiorno.add(const Duration(days: 1));

  return FirebaseFirestore.instance
      .collection('prenotazioni')
      .where('data', isGreaterThanOrEqualTo: Timestamp.fromDate(inizioGiorno))
      .where('data', isLessThan: Timestamp.fromDate(fineGiorno))
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => doc['orario'] as String).toList();
      });
});

// 2. Il Calcolatore aggiornato che FILTRA gli slot occupati
final slotCalculatorProvider = Provider.autoDispose<List<SlotOrario>>((ref) {
  final DateTime dataSelezionata = ref.watch(clientSelectedDateProvider);
  final BookingState bookingState = ref.watch(bookingProvider);
  
  // LEGIAMO GLI ORARI OCCUPATI (se non sono ancora caricati, usiamo lista vuota)
  final List<String> orariOccupati = ref.watch(prenotazioniGiornoProvider).value ?? [];

  final int durataServizioMinuti = bookingState.minutiTotali > 0
      ? bookingState.minutiTotali
      : 15;

  const int oraAperturaMattina = 9;
  const int oraChiusuraMattina = 13;
  const int oraAperturaPomeriggio = 15;
  const int oraChiusuraPomeriggio = 19;

  final List<SlotOrario> slotsCalcolati = <SlotOrario>[];

  void generaGriglia(int oraInizio, int oraFine) {
    DateTime currentTime = DateTime(
      dataSelezionata.year,
      dataSelezionata.month,
      dataSelezionata.day,
      oraInizio,
      0,
    );

    final DateTime orarioChiusura = DateTime(
      dataSelezionata.year,
      dataSelezionata.month,
      dataSelezionata.day,
      oraFine,
      0,
    );

    while (currentTime.isBefore(orarioChiusura)) {
      final String orarioString =
            "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";

      // CONTROLLO FONDAMENTALE: 
      // Se l'orario attuale è nella lista degli occupati, lo saltiamo
      final bool giaPrenotato = orariOccupati.contains(orarioString);

      if (!giaPrenotato) {
        final DateTime orarioFineServizio = currentTime.add(
          Duration(minutes: durataServizioMinuti),
        );

        if (orarioFineServizio.isBefore(orarioChiusura) ||
            orarioFineServizio.isAtSameMomentAs(orarioChiusura)) {
          
          slotsCalcolati.add(SlotOrario(orario: orarioString, isOccupato: false));
        }
      }

      // Ci spostiamo di 15 minuti per il prossimo slot possibile
      currentTime = currentTime.add(const Duration(minutes: 15));
    }
  }

  generaGriglia(oraAperturaMattina, oraChiusuraMattina);
  generaGriglia(oraAperturaPomeriggio, oraChiusuraPomeriggio);

  return slotsCalcolati;
});