import 'package:shavette/features/barbieri/domain/entities/slot_orario.dart';

class Barbiere {
  final String id;
  final String nome;
  final String avatarUrl;
  final List<SlotOrario> slots;
  final bool isAlCompleto;

  Barbiere({
    required this.id,
    required this.nome,
    required this.avatarUrl,
    required this.slots,
    this.isAlCompleto = false,
  });
}
