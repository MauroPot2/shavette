import 'package:flutter_test/flutter_test.dart';
import 'package:shavette/features/appuntamenti/domain/entities/appuntamento.dart';
import 'package:shavette/features/appuntamenti/domain/entities/servizio.dart';
import 'package:shavette/features/appuntamenti/domain/usecases/prenota_appuntamento_usecase.dart';
import 'package:shavette/features/appuntamenti/domain/repositories/appuntamenti_repository.dart';
import 'package:shavette/features/appuntamenti/domain/services/validatore_appuntamenti.dart';

// --- IL NOSTRO CUOCO FINTO (Questa volta tiene traccia di cosa salva) ---
class FakeAppuntamentiRepository implements AppuntamentiRepository {
  List<Appuntamento> databaseFinto = [];

  // Possiamo decidere dall'esterno quali appuntamenti sono già presenti
  FakeAppuntamentiRepository({List<Appuntamento>? iniziali}) {
    if (iniziali != null) {
      databaseFinto.addAll(iniziali);
    }
  }

  @override
  Future<List<Appuntamento>> getAppuntamentiPerData(DateTime data) async {
    return databaseFinto;
  }

  @override
  Future<void> salvaAppuntamento(Appuntamento appuntamento) async {
    databaseFinto.add(appuntamento); // Simula il salvataggio nel DB
  }

  @override
  Future<void> cancellaAppuntamento(String id) async {}

  @override
  Future<Appuntamento?> getAppuntamentoById(String id) async {
    return null;
  }

  @override
  Future<void> aggiornaAppuntamento(Appuntamento appuntamento) async {}
}

void main() {
  // Dati condivisi per i test
  final dataTest = DateTime(2026, 3, 26);
  const servizioTest = Servizio(
    id: 's1',
    nome: 'Taglio',
    durataMinuti: 30,
    prezzo: 20,
  );

  final appuntamentoEsistente = Appuntamento(
    id: 'old_1',
    clienteNome: 'Mario Rossi',
    orarioInizio: DateTime(2026, 3, 26, 10, 0),
    servizioScelto: servizioTest,
  );

  final nuovoAppuntamento = Appuntamento(
    id: 'new_1',
    clienteNome: 'Luigi Verdi',
    orarioInizio: DateTime(
      2026,
      3,
      26,
      10,
      15,
    ), // Si accavalla con Mario Rossi!
    servizioScelto: servizioTest,
  );

  test(
    'Deve lanciare SlotOccupatoException se c\'è sovrapposizione (Il Buttafuori funziona)',
    () async {
      // 1. ARRANGE: Prepariamo il DB finto con un appuntamento già esistente alle 10:00
      final repo = FakeAppuntamentiRepository(
        iniziali: [appuntamentoEsistente],
      );
      final validatore = ValidatoreAppuntamenti();
      final usecase = PrenotaAppuntamentoUseCase(
        repository: repo,
        validatore: validatore,
      );

      // 2 & 3. ACT & ASSERT: Proviamo a salvare Luigi Verdi alle 10:15 e ci aspettiamo un'eccezione
      expect(
        () => usecase.execute(nuovoAppuntamento),
        throwsA(isA<SlotOccupatoException>()),
      );

      // Verifichiamo che il DB finto NON abbia salvato l'intruso
      expect(repo.databaseFinto.length, 1);
    },
  );

  test(
    'Deve salvare l\'appuntamento se lo slot è completamente libero',
    () async {
      // 1. ARRANGE: Il DB finto è vuoto (nessun appuntamento in giornata)
      final repo = FakeAppuntamentiRepository(iniziali: []);
      final validatore = ValidatoreAppuntamenti();
      final usecase = PrenotaAppuntamentoUseCase(
        repository: repo,
        validatore: validatore,
      );

      // 2. ACT: Eseguiamo la prenotazione
      await usecase.execute(nuovoAppuntamento);

      // 3. ASSERT: Verifichiamo che l'appuntamento sia stato aggiunto al DB finto
      expect(repo.databaseFinto.length, 1);
      expect(repo.databaseFinto.first.clienteNome, 'Luigi Verdi');
    },
  );
}
