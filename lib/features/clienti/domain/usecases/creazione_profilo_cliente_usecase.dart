import 'package:shavette/features/clienti/domain/entities/cliente.dart';
import 'package:shavette/features/clienti/domain/entities/telefono.dart';
import 'package:shavette/features/clienti/domain/repositories/clienti_repository.dart';

///Questo use case prende input lo pulisce e crea il profilo cliente.
class CreazioneProfiloClienteUseCase {
  final ClientiRepository repository;

  CreazioneProfiloClienteUseCase({required this.repository});

  /// Il Manager riceve stringhe semplici dall'interfaccia grafica.
  /// Sarà lui a trasformarle negli oggetti complessi del nostro Dominio.
  Future<Cliente> execute({
    required String id,
    required String nome,
    required String cognome,
    required String numeroTelefono,
  }) async {
    // 1. Creiamo e validiamo il telefono. 
    // Se la UI ci passa un numero finto (es. "ciao"), la classe Telefono
    // lancerà una FormatException e il flusso si bloccherà immediatamente qui.
    final telefonoValidato = Telefono(numeroTelefono);

    // 2. Creiamo l'entità Cliente. 
    // È il Manager a guardare l'orologio e a iniettare il tempo di registrazione.
    final nuovoCliente = Cliente(
      id: id,
      nome: nome,
      cognome: cognome,
      telefono: telefonoValidato,
      dataRegistrazione: DateTime.now(), // Il tempo viene deciso ora
    );

    // 3. Firmiamo e salviamo nel database
    await repository.salvaCliente(nuovoCliente);

    // 4. Restituiamo il cliente (utile per la UI per mostrarlo subito a schermo)
    return nuovoCliente;
  }
}
