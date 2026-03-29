import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. USA L'ISTANZA SINGLETON (Obbligatorio in 7.x)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithGoogle() async {
    try {
      // 2. INIZIALIZZAZIONE OBBLIGATORIA (Deve essere chiamata una volta)
      await _googleSignIn.initialize();

      // 3. USA AUTHENTICATE AL POSTO DI SIGNIN
      final googleUser = await _googleSignIn.authenticate();

      // 4. RECUPERO DETTAGLI
      final googleAuth = await googleUser.authentication;

      // 5. CREA CREDENZIALE (Nota: accessToken potrebbe non servire per il login base)
      // Se vuoi solo loggare l'utente, l'idToken è sufficiente per Firebase.
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        /// Se l'IDE segna ancora rosso su accessToken,
        ///  omettilo o usa il nuovo client di autorizzazione
        accessToken: null,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } catch (e) {
      print("Errore critico: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
