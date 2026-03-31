import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider per accedere comodamente al repository da qualsiasi parte dell'app
final barbieriRepositoryProvider = Provider<BarbieriRepository>((ref) {
  return BarbieriRepository(FirebaseFirestore.instance);
});

class BarbieriRepository {
  final FirebaseFirestore _firestore;

  BarbieriRepository(this._firestore);

  /// Crea il profilo del salone su Firestore con tutti i dati dell'onboarding
  Future<void> creaSalone({
    required String uid,
    required String nomeSalone,
    required String piva,
    required String telefono,
    required Map<String, String> indirizzo,
    required String coloreBrand,
    required List<String> staff,
  }) async {
    try {
      // Inizializziamo il Batch per fare scritture multiple in totale sicurezza
      final batch = _firestore.batch();

      // 1. IL DOCUMENTO PRINCIPALE DEL SALONE
      final saloneRef = _firestore.collection('barbieri').doc(uid);

      batch.set(saloneRef, {
        'nome': nomeSalone,
        'piva': piva,
        'telefono': telefono,
        // Firebase supporta le mappe, quindi salva {via, civico, citta, cap} perfettamente
        'indirizzo': indirizzo,
        'coloreBrand': coloreBrand,
        'isAlCompleto': false, // Di default non è al completo
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. POPOLIAMO LA SOTTO-COLLEZIONE DELLO STAFF
      for (final nomeCollaboratore in staff) {
        // .doc() senza parametri genera automaticamente un ID univoco per il collaboratore
        final staffRef = saloneRef.collection('staff').doc();

        batch.set(staffRef, {
          'nome': nomeCollaboratore,
          'createdAt': FieldValue.serverTimestamp(),
          // In futuro potrai aggiungere campi qui: es. fotoUrl, orariPersonalizzati, ecc.
        });
      }

      // 3. ESEGUIAMO TUTTO IN UN COLPO SOLO!
      await batch.commit();
    } catch (e) {
      print("Errore durante la creazione del salone: $e");
      rethrow; // Rilancia l'errore per farlo catturare alla UI (che mostrerà lo SnackBar)
    }
  }
}
