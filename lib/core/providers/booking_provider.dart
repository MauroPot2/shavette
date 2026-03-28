import 'package:flutter_riverpod/legacy.dart';

// Una classe semplice per contenere i dati della prenotazione in corso
class BookingState {
  final String? barbiereId;
  final String? orario;
  final List<String> serviziIds;
  final int minutiTotali;

  BookingState({
    this.barbiereId,
    this.orario,
    this.serviziIds = const [],
    this.minutiTotali = 0,
  });

  // Funzione per aggiornare lo stato senza sovrascrivere tutto
  BookingState copyWith({
    String? barbiereId,
    String? orario,
    List<String>? serviziIds,
    int? minutiTotali,
  }) {
    return BookingState(
      barbiereId: barbiereId ?? this.barbiereId,
      orario: orario ?? this.orario,
      serviziIds: serviziIds ?? this.serviziIds,
      minutiTotali: minutiTotali ?? this.minutiTotali,
    );
  }
}

// Il "Sistema Nervoso" vero e proprio
class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  void setOrario(String barbiereId, String orario) {
    state = state.copyWith(barbiereId: barbiereId, orario: orario);
  }

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

  ///reset provider.
  void reset() {
    // Riportiamo lo stato alle condizioni di fabbrica (tutto vuoto)
    state = BookingState(
      barbiereId: null,
      orario: null,
      serviziIds: [],
      minutiTotali: 0,
    );
  }
}

/// Esponiamo il provider.
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((
  ref,
) {
  return BookingNotifier();
});
