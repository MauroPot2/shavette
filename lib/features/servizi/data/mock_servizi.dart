
import 'package:shavette/features/servizi/domain/entities/servizio.dart'; // Importa il modello

const List<Servizio> listaServizi = [
  Servizio(
    id: '1',
    nome: 'Taglio Gentleman',
    durataMinuti: 30,
    prezzo: 25,
    categoria: 'Capelli',
  ),
  Servizio(
    id: '2',
    nome: 'Taglio + Barba Relax',
    durataMinuti: 60,
    prezzo: 45,
    categoria: 'Combo',
  ),
  Servizio(
    id: '3',
    nome: 'Regolazione Barba',
    durataMinuti: 20,
    prezzo: 15,
    categoria: 'Barba',
  ),
  Servizio(
    id: '4',
    nome: 'Trattamento Viso Hot Towel',
    durataMinuti: 15,
    prezzo: 10,
    categoria: 'Special',
  ),
];