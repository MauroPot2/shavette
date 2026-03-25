import 'package:shavette/features/barbiere/domain/entities/orario_lavorativo.dart';
import 'package:shavette/features/barbiere/domain/entities/pausa.dart';

/// Barbiere nel sistema salone.
class Barbiere {
  /// Crea una nuova istanza di [Barbiere].
  const Barbiere({
    required this.id,
    required this.nome,
    required this.orariStandard,
    // Se non passiamo pause, di default la lista è vuota
    this.pauseProgrammate = const [],
  });

  ///id barbiere univoco.
  final String id;

  ///nome barbiere.
  final String nome;

  ///lista orario lavorativo.
  final List<OrarioLavorativo> orariStandard;

  ///lista pause programmate.
  final List<Pausa> pauseProgrammate;
}
