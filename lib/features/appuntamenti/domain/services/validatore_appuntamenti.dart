import '../entities/appuntamento.dart';

class ValidatoreAppuntamenti {
  /// Riceve un potenziale orario e la lista degli appuntamenti.
  /// Restituisce [true] se c'è un accavallamento (slot occupato),
  /// restituisce [false] se lo slot è libero.
  bool hasSovrapposizione({
    required DateTime inizioNuovo,
    required DateTime fineNuovo,
    required List<Appuntamento> appuntamentiEsistenti,
  }) {
    for (var app in appuntamentiEsistenti) {
      // Regola aurea delle intersezioni temporali:
      // Il nuovo inizia prima che il vecchio finisca, 
      // E il nuovo finisce dopo che il vecchio è iniziato.
      if (inizioNuovo.isBefore(app.orarioFine) && fineNuovo.isAfter(app.orarioInizio)) {
        return true; // Scontro frontale!
      }
    }
    return false; // Via libera!
  }
}