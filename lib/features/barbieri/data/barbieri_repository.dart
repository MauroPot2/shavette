import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider per accedere comodamente 
/// al repository da qualsiasi parte dell'app
final barbieriRepositoryProvider = Provider<BarbieriRepository>((ref) {
  return BarbieriRepository(FirebaseFirestore.instance);
});

class BarbieriRepository {
  final FirebaseFirestore _firestore;

  BarbieriRepository(this._firestore);

  /// Crea il profilo del salone su Firestore
  Future<void> creaSalone({
    required String uid,
    required String nomeSalone,
    required String indirizzo,
  }) async {
    try {
      /// Usiamo l'UID dell'utente come ID
      ///  del documento per trovarlo facilmente in futuro
      await _firestore.collection('barbieri').doc(uid).set({
        'nome': nomeSalone,
        'indirizzo': indirizzo,
        'isAlCompleto': false, // Di default non è al completo
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Errore durante la creazione del salone: $e');
      rethrow;
    }
  }
}
