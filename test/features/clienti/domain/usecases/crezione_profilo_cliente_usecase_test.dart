import 'package:flutter_test/flutter_test.dart';
import 'package:shavette/features/clienti/domain/entities/cliente.dart';
import 'package:shavette/features/clienti/domain/repositories/clienti_repository.dart';
import 'package:shavette/features/clienti/domain/usecases/creazione_profilo_cliente_usecase.dart';

// --- IL NOSTRO CUOCO FINTO ---
class FakeClientiRepository implements ClientiRepository {
  final List<Cliente> databaseClienti = [];

  @override
  Future<void> salvaCliente(Cliente cliente) async {
    databaseClienti.add(cliente); // Simula il salvataggio
  }

  @override
  Future<Cliente?> getClienteById(String id) async {
    // Al momento non ci serve testare la lettura, ma il contratto esige la firma
    return null;
  }
}

void main() {
  group('Collaudo CreazioneProfiloClienteUseCase', () {
    
    test('Deve salvare il cliente se il numero di telefono è formattato correttamente', () async {
      // 1. ARRANGE
      final repo = FakeClientiRepository();
      final usecase = CreazioneProfiloClienteUseCase(repository: repo);

      // 2. ACT
      final clienteCreato = await usecase.execute(
        id: 'c1',
        nome: 'Luca',
        cognome: 'Bianchi',
        numeroTelefono: '+39 333 1234567', // Formato corretto (anche con gli spazi)
      );

      // 3. ASSERT
      expect(repo.databaseClienti.length, 1); // Il database finto ha salvato 1 elemento
      expect(clienteCreato.nomeCompleto, 'Luca Bianchi');
      expect(clienteCreato.noShowCount, 0); // Di default deve essere 0
      expect(clienteCreato.isBloccato, false); // Di default non deve essere bloccato
    });

    test('Deve lanciare FormatException e bloccare tutto se il numero è falso', () async {
      // 1. ARRANGE
      final repo = FakeClientiRepository();
      final usecase = CreazioneProfiloClienteUseCase(repository: repo);

      // 2 & 3. ACT & ASSERT
      expect(
        () => usecase.execute(
          id: 'c2',
          nome: 'Mario',
          cognome: 'Furbetto',
          numeroTelefono: 'ciao1234', // Tentativo di frode!
        ),
        throwsA(isA<FormatException>()), // Ci aspettiamo che esploda
      );

      // Assicuriamoci che l'intruso non sia stato salvato nel database!
      expect(repo.databaseClienti.isEmpty, true);
    });

  });
}