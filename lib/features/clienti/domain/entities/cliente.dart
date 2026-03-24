class Cliente {
  final String id;
  final String nome;
  final String cognome;
  final String telefono;
  final int noShowCount;

  const Cliente({
    required this.id,
    required this.nome,
    required this.cognome,
    required this.telefono,
    this.noShowCount = 0,
  });

  //se il cliente buca 3 o + appuntamenti chiediamo la caparra obbligatoria
  bool get requestDeposit => noShowCount >= 3;
}