
///classe telefono che ci serve per validare i numeri di telefono inseriti
class Telefono {
    ///costruttore della classe telefono che  valida il formato.
    Telefono(this.valore) {
    _validaFormato(valore);
  }

  ///numero di telefono.
  final String valore;



  void _validaFormato(String numero) {
    // Rimuoviamo gli spazi vuoti che l'utente potrebbe inserire per sbaglio
    final numeroPulito = numero.replaceAll(' ', '');

    /// RegEx base per i numeri di telefono (accetta il + iniziale e ///poi solo numeri, minimo 8, massimo 15)
    final regex = RegExp(r'^\+?[0-9]{8,15}$');

    if (!regex.hasMatch(numeroPulito)) {
      throw FormatException('Numero di telefono non valido: $numero');
    }
  }

  @override
  String toString() => valore;
}
