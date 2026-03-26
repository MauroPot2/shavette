import 'package:shavette/features/appuntamenti/domain/entities/servizio.dart';
import 'package:shavette/features/appuntamenti/domain/repositories/appuntamenti_repository.dart';
import 'package:shavette/features/appuntamenti/domain/services/validatore_appuntamenti.dart';
import 'package:shavette/features/barbiere/domain/entities/repositories/barbiere_repository.dart';

///questa classe calcola gli slot disponibili adatti ad una nuova prenotazione
class CalcolaSlotDisponibiliUseCase {

  /// Dependency Injection: passiamo le interfacce dal costruttore
  CalcolaSlotDisponibiliUseCase({
    required this.barbiereRepository,
    required this.appuntamentiRepository,
  });

  /// Il "Manager" ha bisogno dei "Magazzinieri" per lavorare
  final BarbiereRepository barbiereRepository;
  final AppuntamentiRepository appuntamentiRepository;

  

  /// Il metodo principale che esegue l'azione
  Future<List<DateTime>> execute({
    required String barbiereId,
    required DateTime dataScelta,
    required Servizio servizioScelto,
  }) async {
    // 1. Recupera chi è il barbiere
    final barbiere = await barbiereRepository.getBarbiere(barbiereId);
    if (barbiere == null) return []; // Sicurezza: se non esiste, niente slot

    // 2. Recupera gli appuntamenti già presi per quel giorno
    final appuntamentiDelGiorno = await appuntamentiRepository
        .getAppuntamentiPerData(dataScelta);

    // 3. Scopriamo se il barbiere è aperto in quel giorno della settimana
    // weekday in Dart: 1=Lunedì, 7=Domenica
    final orarioOggi = barbiere.orariStandard
        .where((orario) => orario.giornoDellaSettimana == dataScelta.weekday)
        .firstOrNull;

    if (orarioOggi == null) return []; // È il suo giorno di chiusura!

    // 4. Prepariamo la matematica del tempo
    List<DateTime> slotDisponibili = [];

    DateTime orarioCorrente = DateTime(
      dataScelta.year,
      dataScelta.month,
      dataScelta.day,
      orarioOggi.oraApertura,
      orarioOggi.minutoApertura,
    );
    DateTime orarioChiusura = DateTime(
      dataScelta.year,
      dataScelta.month,
      dataScelta.day,
      orarioOggi.oraChiusura,
      orarioOggi.minutoChiusura,
    );

    // Decidiamo ogni quanti minuti la griglia degli orari scorre (es. ogni 15 min)
    const int intervalloGrigliaMinuti = 15;

    final validatore = ValidatoreAppuntamenti();
    // 5. Il Ciclo di Calcolo (Finché l'orario + durata servizio non supera la chiusura)
    while (orarioCorrente
            .add(Duration(minutes: servizioScelto.durataMinuti))
            .compareTo(orarioChiusura) <=
        0) {
      DateTime potenzialeFine = orarioCorrente.add(
        Duration(minutes: servizioScelto.durataMinuti),
      );

      // Controlliamo se questo specifico blocco di tempo si scontra ///con qualcosa
      bool isOccupato = validatore.hasSovrapposizione(
        inizioNuovo: orarioCorrente,
        fineNuovo: potenzialeFine,
        appuntamentiEsistenti: appuntamentiDelGiorno,
      );

      if (!isOccupato) {
        slotDisponibili.add(orarioCorrente);
      }

      // Mandiamo avanti l'orologio per testare il prossimo slot
      orarioCorrente = orarioCorrente.add(
        const Duration(minutes: intervalloGrigliaMinuti),
      );
    }

    return slotDisponibili;
  }
}
