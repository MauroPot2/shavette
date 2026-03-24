import 'orario_lavorativo.dart';
import 'pausa.dart';

class Barbiere {
  final String id;
  final String nome;
  final List<OrarioLavorativo> orariStandard;
  final List<Pausa> pauseProgrammate;

  const Barbiere({
    required this.id,
    required this.nome,
    required this.orariStandard,
    // Se non passiamo pause, di default la lista è vuota
    this.pauseProgrammate = const [], 
  });
}