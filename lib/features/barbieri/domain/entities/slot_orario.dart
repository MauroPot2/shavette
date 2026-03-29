// lib/features/barbieri/domain/entities/slot_orario.dart

class SlotOrario {
  final String orario;
  final bool isOccupato;

  const SlotOrario({
    required this.orario,
    this.isOccupato = false,
  });
}