import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';
import 'package:shavette/features/barbieri/domain/entities/slot_orario.dart';

final List<Barbiere> barbieriDelGiorno = [
  Barbiere(
    id: '1',
    nome: 'Barber Gio',
    avatarUrl: 'https://i.pravatar.cc/150?u=1',
    slots: [
      const SlotOrario(orario: '09:00'),
      const SlotOrario(orario: '09:30', isOccupato: true),
      const SlotOrario(orario: '10:00'),
      const SlotOrario(orario: '10:30'),
      const SlotOrario(orario: '11:00'),
    ],
  ),
  Barbiere(
    id: '2',
    nome: 'Barber Beps',
    avatarUrl: 'https://i.pravatar.cc/150?u=2',
    isAlCompleto: true,
    slots: const [
      SlotOrario(orario: '09:00'),
      SlotOrario(orario: '09:30'),
      SlotOrario(orario: '10:00'),
      SlotOrario(orario: '10:30'),
      SlotOrario(orario: '11:00'),
      SlotOrario(orario: '11:30'),
    ],
  ),
  Barbiere(
    id: '3',
    nome: 'Barber Marco',
    avatarUrl: 'https://i.pravatar.cc/150?u=3',
    slots: [
      const SlotOrario(orario: '15:00'),
      const SlotOrario(orario: '15:30'),
      const SlotOrario(orario: '16:00'),
      const SlotOrario(orario: '16:30'),
    ],
  ),
];
