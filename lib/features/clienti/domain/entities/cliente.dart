import 'package:shavette/features/clienti/domain/entities/telefono.dart';
///La classe cliente crea i singoli clienti con le informazioni basiche.
class Cliente {
  ///Costruttori di cliente
   Cliente({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.telefono,
    required this.dataRegistrazione,
    this.noShowCount = 0,
    this.isBloccato = false,
    this.metadata = const {},
  });

  final String id;
  final String nome;
  final String cognome;
  final Telefono telefono;

  ///metriche di business con valori di default.
  final int noShowCount;
  final bool isBloccato;
  final DateTime dataRegistrazione;

  ///Estensione white-label metadata
  final Map<String, dynamic> metadata;

  ///Nome completo cliente
  String get nomeCompleto => '$nome $cognome';
  //se il cliente buca 3 o + appuntamenti chiediamo la caparra obbligatoria
  bool get requestDeposit => noShowCount >= 3;
}
