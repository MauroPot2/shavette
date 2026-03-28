import 'package:shavette/features/prenotazioni/domain/models/barbiere.dart';

class TimeUtils {
  /// Trova il primo orario disponibile che
  /// possa contenere l'intera durata del servizio,
  /// cercando a partire dall'orario originariamente selezionato.
  static String? trovaProssimoSlotDisponibile({
    required List<MockSlot> slotsDelBarbiere,
    required String orarioSelezionato,
    required int durataServizioMinuti,
  }) {
    // 1. Quanti blocchi da 30 minuti ci servono?
    // Usiamo .ceil() per arrotondare per eccesso:
    // 20 min -> 1 blocco, 45 min -> 2 blocchi, 60 min -> 2 blocchi.
    final blocchiNecessari = (durataServizioMinuti / 30).ceil();

    // 2. Troviamo da dove partire nella lista
    final indicePartenza = slotsDelBarbiere.indexWhere(
      (s) => s.orario == orarioSelezionato,
    );

    // Se per qualche motivo non troviamo l'orario di partenza, ci fermiamo
    if (indicePartenza == -1) return null;

    // 3. Iniziamo a scorrere l'agenda a partire dallo slot
    //SUCCESSIVO a quello scelto
    // Il limite del ciclo for garantisce che non usciamo
    // fuori dall'array a fine giornata
    for (
      int i = indicePartenza + 1;
      i <= slotsDelBarbiere.length - blocchiNecessari;
      i++
    ) {
      bool sequenzaLibera = true;

      // 4. Per ogni orario, controlliamo se i
      //successivi "N" blocchi sono tutti liberi
      for (var j = 0; j < blocchiNecessari; j++) {
        if (slotsDelBarbiere[i + j].isOccupato) {
          sequenzaLibera = false;
          break; // Appena troviamo un muro,
          //smettiamo di controllare questa sequenza
        }
      }

      ///Il ciclo torna lo slot libero
      if (sequenzaLibera) {
        return slotsDelBarbiere[i].orario; // Es: ritorna "11:30"
      }
    }

    ///Se arriviamo qui, il barbiere non ha
    ///più buchi grandi abbastanza per oggi
    return null;
  }

  /// Calcola quanti minuti consecutivi sono liberi a partire da un certo orario
  static int calcolaMinutiLiberiReali({
    required List<MockSlot>
    slotsDelBarbiere, // Usa dynamic o MockSlot se l'hai importato
    required String? orario,
  }) {
    if (orario == null) return 0;

    final startIndex = slotsDelBarbiere.indexWhere((s) => s.orario == orario);
    if (startIndex == -1) return 0;

    int slotLiberiConsecutivi = 0;
    for (int i = startIndex; i < slotsDelBarbiere.length; i++) {
      if (slotsDelBarbiere[i].isOccupato) break;
      slotLiberiConsecutivi++;
    }

    return slotLiberiConsecutivi * 30;
  }
}
