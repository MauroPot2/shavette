class Servizio {
  const Servizio({
    required this.id,
    required this.nome,
    required this.durataMinuti,
    required this.prezzo,
    required this.categoria,
  });

  final String id;
  final String nome;
  final int durataMinuti;
  final double prezzo;
  final String categoria;
}
