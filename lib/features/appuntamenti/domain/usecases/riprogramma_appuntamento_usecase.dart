import 'package:shavette/features/appuntamenti/domain/entities/appuntamento.dart';
import 'package:shavette/features/appuntamenti/domain/repositories/appuntamenti_repository.dart';
import 'package:shavette/features/appuntamenti/domain/services/validatore_appuntamenti.dart';
// Importiamo l'eccezione che avevamo già creato per la prenotazione!
import 'package:shavette/features/appuntamenti/domain/usecases/prenota_appuntamento_usecase.dart'; 

class RiprogrammaAppuntamentoUseCase {
  final AppuntamentiRepository repository;
  final ValidatoreAppuntamenti validatore;

  RiprogrammaAppuntamentoUseCase({
    required this.repository,
    required this.validatore,
  });

  Future<void> execute({
    required Appuntamento appuntamentoEsistente,
    required DateTime nuovoOrarioInizio,
  }) async {
    // 1. Calcoliamo il nuovo orario di fine previsto
    final nuovoOrarioFine = nuovoOrarioInizio.add(
      Duration(minutes: appuntamentoEsistente.servizioScelto.durataMinuti),
    );

    // 2. Recuperiamo gli appuntamenti GIA' PRESI per la nuova data
    final appuntamentiDelNuovoGiorno = await repository.getAppuntamentiPerData(nuovoOrarioInizio);

    // TRUCCO DA PRO: Rimuoviamo l'appuntamento stesso dalla lista dei controlli!
    // Altrimenti, se il cliente sposta il taglio di soli 10 minuti nello stesso giorno,
    // il Validatore penserebbe che si sta scontrando con... se stesso!
    final appuntamentiDaControllare = appuntamentiDelNuovoGiorno
        .where((app) => app.id != appuntamentoEsistente.id)
        .toList();

    // 3. Il Buttafuori controlla se il nuovo slot è libero
    final isOccupato = validatore.hasSovrapposizione(
      inizioNuovo: nuovoOrarioInizio,
      fineNuovo: nuovoOrarioFine,
      appuntamentiEsistenti: appuntamentiDaControllare,
    );

    if (isOccupato) {
      throw SlotOccupatoException('Impossibile riprogrammare: il nuovo orario è già occupato.');
    }

    // 4. Poiché le variabili della classe Appuntamento sono "final", ne creiamo 
    // una nuova copia identica, cambiando solo l'orario di inizio.
    final appuntamentoAggiornato = Appuntamento(
      id: appuntamentoEsistente.id,
      clienteNome: appuntamentoEsistente.clienteNome,
      servizioScelto: appuntamentoEsistente.servizioScelto,
      orarioInizio: nuovoOrarioInizio,
    );

    // 5. Salviamo l'aggiornamento
    await repository.aggiornaAppuntamento(appuntamentoAggiornato);
  }
}