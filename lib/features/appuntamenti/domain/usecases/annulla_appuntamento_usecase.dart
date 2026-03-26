import 'package:shavette/features/appuntamenti/domain/repositories/appuntamenti_repository.dart';

/// Eccezioni di Dominio personalizzate
class AppuntamentoNonTrovatoException implements Exception {
  final String messaggio = 'Appuntamento non trovato nel sistema.';
  @override
  String toString() => messaggio;
}

class PreavvisoBreveException implements Exception {
  final String messaggio;
  PreavvisoBreveException(this.messaggio);
  @override
  String toString() => messaggio;
}

class AnnullaAppuntamentoUseCase {
  final AppuntamentiRepository repository;

  AnnullaAppuntamentoUseCase({required this.repository});

  /// [orarioRichiesta] è il momento esatto in cui il cliente preme "Annulla"
  /// [forzaAnnullamento] serve al Barbiere (Admin) per cancellare ignorando le regole
  Future<void> execute({
    required String appuntamentoId,
    required DateTime orarioRichiesta,
    bool forzaAnnullamento = false,
  }) async {
    // 1. Troviamo l'appuntamento
    final appuntamento = await repository.getAppuntamentoById(appuntamentoId);
    if (appuntamento == null) {
      throw AppuntamentoNonTrovatoException();
    }

    // 2. Calcoliamo quante ore mancano al taglio
    final oreDiPreavviso = appuntamento.orarioInizio.difference(orarioRichiesta).inHours;

    // 3. Regola di Business: Preavviso minimo di 24 ore
    // Se il cliente sta cancellando all'ultimo minuto e non stiamo forzando l'azione...
    if (oreDiPreavviso < 24 && !forzaAnnullamento) {
      throw PreavvisoBreveException(
        'Attenzione: Mancano meno di 24 ore. Verrà applicata una penale per la cancellazione.',
      );
    }

    // 4. Se tutto è in regola (o il barbiere forza), procediamo all'eliminazione
    await repository.cancellaAppuntamento(appuntamentoId);
  }
}