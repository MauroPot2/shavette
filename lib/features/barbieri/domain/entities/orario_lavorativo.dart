class OrarioLavorativo {
  // In Dart, i giorni vanno da 1 (Lunedì) a 7 (Domenica)
  final int giornoDellaSettimana; 
  final int oraApertura;
  final int minutoApertura;
  final int oraChiusura;
  final int minutoChiusura;

  const OrarioLavorativo({
    required this.giornoDellaSettimana,
    required this.oraApertura,
    this.minutoApertura = 0,
    required this.oraChiusura,
    this.minutoChiusura = 0,
  });
}