import '../pausa.dart';
import '../barbiere.dart';

abstract class BarbiereRepository {
  Future<Barbiere?> getBarbiere(String id);

  Future<void> aggiornaPauseProgrammate(String barbiereId, List<Pausa> nuovePause);

}