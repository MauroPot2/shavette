class Pausa {
  final DateTime inizio;
  final DateTime fine;
  final String motivo;

  const Pausa({
    required this.inizio,
    required this.fine,
    this.motivo = 'Pausa standard',
  });

  // Logica pura: calcola quanto dura questa pausa
  Duration get durata => fine.difference(inizio);
}