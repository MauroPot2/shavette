import 'servizio.dart';

class Appuntamento {
  final String id;
  final String clienteNome;
  final DateTime orarioInizio;
  final Servizio servizioScelto;

  const Appuntamento({
    required this.id,
    required this.clienteNome,
    required this.orarioInizio,
    required this.servizioScelto,
  });

  DateTime get orarioFine {
    return orarioInizio.add(Duration(minutes: servizioScelto.durataMinuti));
  }
}
