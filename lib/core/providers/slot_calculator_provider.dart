//
// ignore_for_file: public_member_api_docs

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/barbieri/domain/entities/slot_orario.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';

// 1. Dichiariamo esplicitamente il tipo del provider stesso
final slotCalculatorProvider = Provider.autoDispose<List<SlotOrario>>((
  ref,
) {
  // 2. Dichiariamo esplicitamente i tipi letti da Riverpod
  final DateTime dataSelezionata = ref.watch(clientSelectedDateProvider);
  final BookingState bookingState = ref.watch(bookingProvider);

  // 3. Dichiariamo che i minuti sono un numero intero (int)
  final int durataServizioMinuti = bookingState.minutiTotali > 0
      ? bookingState.minutiTotali
      : 15;

  // 4. Dichiariamo che gli orari sono numeri interi (int)
  const int oraAperturaMattina = 9;
  const int oraChiusuraMattina = 13;
  const int oraAperturaPomeriggio = 15;
  const int oraChiusuraPomeriggio = 19;

  // 5. Inizializziamo la lista dicendo esplicitamente cosa contiene
  final List<SlotOrario> slotsCalcolati = <SlotOrario>[];

  // 6. Funzione con tipi espliciti
  void generaGriglia(int oraInizio, int oraFine) {
    // Specifichiamo che currentTime è un DateTime
    DateTime currentTime = DateTime(
      dataSelezionata.year,
      dataSelezionata.month,
      dataSelezionata.day,
      oraInizio,
      0,
    );

    // Specifichiamo che orarioChiusura è un DateTime
    final DateTime orarioChiusura = DateTime(
      dataSelezionata.year,
      dataSelezionata.month,
      dataSelezionata.day,
      oraFine,
      0,
    );

    while (currentTime.isBefore(orarioChiusura)) {
      // Specifichiamo il tipo del calcolo
      final DateTime orarioFineServizio = currentTime.add(
        Duration(minutes: durataServizioMinuti),
      );

      if (orarioFineServizio.isBefore(orarioChiusura) ||
          orarioFineServizio.isAtSameMomentAs(orarioChiusura)) {
        // Specifichiamo che la stringa formattata è una String
        final String orarioString =
            "${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}";

        slotsCalcolati.add(SlotOrario(orario: orarioString, isOccupato: false));
      }

      currentTime = currentTime.add(const Duration(minutes: 15));
    }
  }

  generaGriglia(oraAperturaMattina, oraChiusuraMattina);
  generaGriglia(oraAperturaPomeriggio, oraChiusuraPomeriggio);

  return slotsCalcolati;
});
