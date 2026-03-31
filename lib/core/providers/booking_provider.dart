import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// 
class BookingState {
  final String? saloneId;    // ID del salone scelto nella Home
  final String? barbiereId; // ID del barbiere scelto nella griglia oraria
  final String? orario;      // Orario scelto (es. "10:30")
  final List<String> serviziIds;
  final int minutiTotali;

  BookingState({
    this.saloneId,
    this.barbiereId,
    this.orario,
    this.serviziIds = const [],
    this.minutiTotali = 0,
  });

  // Crea una copia dello stato aggiornando solo i campi necessari
  BookingState copyWith({
    String? saloneId,
    String? barbiereId,
    String? orario,
    List<String>? serviziIds,
    int? minutiTotali,
  }) {
    return BookingState(
      saloneId: saloneId ?? this.saloneId,
      barbiereId: barbiereId ?? this.barbiereId,
      orario: orario ?? this.orario,
      serviziIds: serviziIds ?? this.serviziIds,
      minutiTotali: minutiTotali ?? this.minutiTotali,
    );
  }
}

/// 2. NOTIFIER: La logica che modifica la "valigia"
class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  // Settiamo il salone (chiamato nella Home Cliente)
  void setSalone(String id) {
    state = state.copyWith(saloneId: id);
  }

  // Settiamo barbiere e orario (chiamato nella Selezione Orario)
  void setOrario(String barbiereId, String orario) {
    state = state.copyWith(barbiereId: barbiereId, orario: orario);
  }

  // Aggiunge o rimuove un servizio ricalcolando il tempo totale
  void toggleServizio(String servizioId, int durata) {
    final nuoviServizi = List<String>.from(state.serviziIds);
    int nuovoTempo = state.minutiTotali;

    if (nuoviServizi.contains(servizioId)) {
      nuoviServizi.remove(servizioId);
      nuovoTempo -= durata;
    } else {
      nuoviServizi.add(servizioId);
      nuovoTempo += durata;
    }
    state = state.copyWith(serviziIds: nuoviServizi, minutiTotali: nuovoTempo);
  }

  // Resetta tutto per una nuova prenotazione
  void reset() {
    state = BookingState();
  }
}

/// 3. I PROVIDER ESPOSTI
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});

// Tiene traccia del salone selezionato per filtrare lo staffSaloneProvider
final selectedSaloneProvider = StateProvider<String?>((ref) => null);

// Legge tutti i saloni disponibili su Firestore per mostrarli nella Home
final listaSaloniProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('barbieri')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => {
            'id': doc.id,
            ...doc.data(),
          }).toList());
});