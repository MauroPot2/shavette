import 'package:shavette/features/clienti/domain/entities/cliente.dart';
///Manager di registrazione cliente.
abstract class ClientiRepository {
  /// Salva un nuovo cliente appena creato
  Future<void> salvaCliente(Cliente cliente);
  
  /// Recupera un cliente per ID (ci servirà in futuro per le prenotazioni)
  Future<Cliente?> getClienteById(String id);
}