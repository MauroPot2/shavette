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

  // --- LOGIN CON GOOGLE (Versione 7.x) ---
  Future<User?> signInWithGoogle() async {
    try {
      // 2. INIZIALIZZAZIONE OBBLIGATORIA
      await _googleSignIn.initialize();

      // 3. USA AUTHENTICATE AL POSTO DI SIGNIN
      final googleUser = await _googleSignIn.authenticate();

      // 4. RECUPERO DETTAGLI
      final googleAuth = await googleUser.authentication;

      // 5. CREA CREDENZIALE
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    } catch (e) {
      print("Errore critico Google Sign In: $e");
      rethrow;
    }
  }

  // --- NUOVO: REGISTRAZIONE EMAIL ---
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Errore Registrazione Email: $e");
      rethrow;
    }
  }

  // --- NUOVO: LOGIN EMAIL ---
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Errore Login Email: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Errore durante il Sign Out: $e");
      rethrow;
    }
  }
}