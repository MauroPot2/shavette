import 'package:flutter_test/flutter_test.dart';
import 'package:shavette/features/appuntamenti/domain/entities/appuntamento.dart';
import 'package:shavette/features/appuntamenti/domain/entities/servizio.dart';
import 'package:shavette/features/appuntamenti/domain/usecases/calcola_slot_disponibili_usecase.dart';
import 'package:shavette/features/appuntamenti/domain/repositories/appuntamenti_repository.dart';
import 'package:shavette/features/barbiere/domain/entities/barbiere.dart';
import 'package:shavette/features/barbiere/domain/entities/orario_lavorativo.dart';
import 'package:shavette/features/barbiere/domain/entities/pausa.dart';
import 'package:shavette/features/barbiere/domain/entities/repositories/barbiere_repository.dart';

// --- I NOSTRI CUOCHI FINTI (FAKES) ---

class FakeBarbiereRepository implements BarbiereRepository {
  @override
  Future<Barbiere?> getBarbiere(String id) async {
    // Creiamo un barbiere finto aperto il Lunedì (giorno 1) dalle 09:00 alle 18:00
    return const Barbiere(
      id: 'b1',
      nome: 'Mauro',
      orariStandard: [
        OrarioLavorativo(
          giornoDellaSettimana: 1,
          oraApertura: 9,
          oraChiusura: 18,
        ),
      ],
    );
  }

  @override
  Future<void> aggiornaPauseProgrammate(
    String barbiereId,
    List<Pausa> nuovePause,
  ) async {}
}

class FakeAppuntamentiRepository implements AppuntamentiRepository {
  @override
  Future<List<Appuntamento>> getAppuntamentiPerData(DateTime data) async {
    // Simuliamo che ci sia GIA' un taglio prenotato dalle 10:00 alle 10:30
    return [
      Appuntamento(
        id: 'app1',
        clienteNome: 'Mario Rossi',
        orarioInizio: DateTime(data.year, data.month, data.day, 10, 0),
        servizioScelto: const Servizio(
          id: 's1',
          nome: 'Taglio',
          durataMinuti: 30,
          prezzo: 20.0,
        ),
      ),
    ];
  }

  @override
  Future<void> salvaAppuntamento(Appuntamento appuntamento) async {}

  @override
  Future<void> cancellaAppuntamento(String id) async {}
  
  @override
  Future<Appuntamento?> getAppuntamentoById(String id) async {
    return null;
  }
}

// --- IL COLLAUDO VERO E PROPRIO ---

void main() {
  test(
    'L\'algoritmo deve escludere lo slot delle 10:00 se c\'è già un appuntamento',
    () async {
      // 1. ARRANGE (Prepara il tavolo)
      final barbiereRepo = FakeBarbiereRepository();
      final appuntamentiRepo = FakeAppuntamentiRepository();
      final usecase = CalcolaSlotDisponibiliUseCase(
        barbiereRepository: barbiereRepo,
        appuntamentiRepository: appuntamentiRepo,
      );

      // Dati finti per il calcolo: Un lunedì qualsiasi e un taglio da 30 minuti
      final dataTest = DateTime(2026, 3, 23); // Il 23 Marzo 2026 è un Lunedì
      const servizioTest = Servizio(
        id: 's1',
        nome: 'Taglio',
        durataMinuti: 30,
        prezzo: 20,
      );

      // 2. ACT (Esegui l'azione del Manager)
      final slotCalcolati = await usecase.execute(
        barbiereId: 'b1',
        dataScelta: dataTest,
        servizioScelto: servizioTest,
      );

      // 3. ASSERT (Verifica che la matematica sia corretta)
      final slotDelleNove = DateTime(2026, 3, 23, 9, 0);
      final slotDelleDieci = DateTime(2026, 3, 23, 10, 0);

      // Ci aspettiamo che alle 09:00 il barbiere sia libero (il test passa se è VERO)
      expect(slotCalcolati.contains(slotDelleNove), isTrue);

      // Ci aspettiamo che alle 10:00 il barbiere NON sia libero (il test passa se è FALSO)
      expect(slotCalcolati.contains(slotDelleDieci), isFalse);
    },
  );
}
