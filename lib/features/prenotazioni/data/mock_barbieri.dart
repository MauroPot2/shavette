import 'package:shavette/features/prenotazioni/domain/models/barbiere.dart';

final List<MockBarbiere> barbieriDelGiorno = [
  MockBarbiere(
    id: '1',
    nome: 'Barber Gio\'',
    avatarUrl: 'https://i.pravatar.cc/150?u=1',
    slots: [
      MockSlot('09:00'),
      MockSlot('09:30', isOccupato: true),
      MockSlot('10:00'),
      MockSlot('10:30'),
      MockSlot('11:00'),
    ],
  ),
  MockBarbiere(
    id: '2',
    nome: 'Barber Beps',
    avatarUrl: 'https://i.pravatar.cc/150?u=2',
    isAlCompleto: true,
    slots: [],
  ),
  MockBarbiere(
    id: '3',
    nome: 'Barber Marco',
    avatarUrl: 'https://i.pravatar.cc/150?u=3',
    slots: [
      MockSlot('15:00'),
      MockSlot('15:30'),
      MockSlot('16:00'),
      MockSlot('16:30'),
    ],
  ),
];
