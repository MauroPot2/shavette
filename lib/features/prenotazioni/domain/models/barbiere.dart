class MockSlot {
  final String orario;
  final bool isOccupato;

  MockSlot(this.orario, {this.isOccupato = false});
}

class MockBarbiere {
  final String id;
  final String nome;
  final String avatarUrl;
  final List<MockSlot> slots;
  final bool isAlCompleto;

  MockBarbiere({
    required this.id,
    required this.nome,
    required this.avatarUrl,
    required this.slots,
    this.isAlCompleto = false,
  });
}
