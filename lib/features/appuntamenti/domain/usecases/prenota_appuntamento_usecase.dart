import 'package:shavette/features/appuntamenti/domain/entities/appuntamento.dart';
import 'package:shavette/features/appuntamenti/domain/repositories/appuntamenti_repository.dart';
import 'package:shavette/features/appuntamenti/domain/services/validatore_appuntamenti.dart';

/// 1. Creiamo un'eccezione personalizzata di Dominio
class SlotOccupatoException implements Exception {
  final String messaggio;
  SlotOccupatoException(this.messaggio);
  
  @override
  String toString() => messaggio;
}

class PrenotaAppuntamentoUseCase {

  PrenotaAppuntamentoUseCase({
      required this.repository,
      required this.validatore,
    });


  final AppuntamentiRepository repository;
  final ValidatoreAppuntamenti validatore;

  // Dependency Injection
 
  Future<void> execute(Appuntamento nuovoAppuntamento) async {
    // 2. Recuperiamo gli appuntamenti GIA' SALVATI per quel giorno
    final appuntamentiDelGiorno = await repository.getAppuntamentiPerData(
      nuovoAppuntamento.orarioInizio,
    );

    // 3. Controllo dell'ultimo millisecondo (Concurrency check)
    final isOccupato = validatore.hasSovrapposizione(
      inizioNuovo: nuovoAppuntamento.orarioInizio,
      fineNuovo: nuovoAppuntamento.orarioFine,
      appuntamentiEsistenti: appuntamentiDelGiorno,
    );

    // 4. Se qualcuno ci ha rubato il posto, blocchiamo tutto!
    if (isOccupato) {
      throw SlotOccupatoException('Attenzione: Lo slot selezionato non è più disponibile.');
    }

    // 5. Se il controllo è superato, salviamo definitivamente
    await repository.salvaAppuntamento(nuovoAppuntamento);
  }
}