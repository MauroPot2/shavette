import '../entities/appuntamento.dart';

abstract class AppuntamentiRepository {
  // Read (C-R-UD)
  Future<List<Appuntamento>> getAppuntamentiPerData(DateTime data);
  
  // Create (C-R-UD)
  Future<void> salvaAppuntamento(Appuntamento appuntamento);
  
  // Delete (CRU-D-)
  Future<void> cancellaAppuntamento(String id);
}