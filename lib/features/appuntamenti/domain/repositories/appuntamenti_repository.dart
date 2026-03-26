import 'package:shavette/features/appuntamenti/domain/entities/appuntamento.dart';


///lista delle operazioni che possiamo fare con gli appuntamenti
abstract class AppuntamentiRepository {
  /// Read (C-R-UD)
  Future<List<Appuntamento>> getAppuntamentiPerData(DateTime data);
  
  /// Create (C-R-UD)
  Future<void> salvaAppuntamento(Appuntamento appuntamento);

  /// Update (CR-U-D)
  Future<void> aggiornaAppuntamento(Appuntamento appuntamento);
  
  /// Delete (CRU-D-)
  Future<void> cancellaAppuntamento(String id);

  /// Read: Recupera un singolo appuntamento tramite il suo ID
  Future<Appuntamento?> getAppuntamentoById(String id);
}