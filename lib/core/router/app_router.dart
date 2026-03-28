import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

// --- IMPORTS DELLE TUE SCHERMATE ---
import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/features/auth/presentation/screens/login_screen.dart';
import 'package:shavette/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:shavette/features/clienti/presentation/screens/client_home_screen.dart';
import 'package:shavette/features/dashboard/presentation/screens/dashboard_screen.dart'; // Questa è la HOME CLIENTE
import 'package:shavette/features/prenotazioni/presentation/screens/riepilogo_prenotazione_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/presentation/screens/menu_servizi_screen.dart';

// --- IMPORTS DEI NUOVI PLACEHOLDER (Aggiusta i percorsi se serve) ---

// MOCK: Provider temporaneo per il ruolo finché non lo colleghiamo a Firestore
final userRoleProvider = StateProvider<String?>((ref) => null);

/// Il nostro navigatore di schermate dinamico gestito da Riverpod
final routerProvider = Provider<GoRouter>((ref) {
  // Ascoltiamo lo stato di Firebase (loggato/non loggato)
  final authState = ref.watch(authStateProvider);
  // Ascoltiamo il ruolo (barbiere/cliente/null)
  final userRole = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/login',

    // 🛡️ LA GUARDIA DI SICUREZZA (Redirect Logic)
    redirect: (context, state) {
      // Se Firebase sta ancora caricando, non facciamo nulla
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. Se non sei loggato, rimani (o torna) al Login
      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      // 2. Se sei loggato ma sei nella pagina di Login, ti smistiamo
      if (isLoggingIn) {
        if (userRole == null) return '/role-selection';
        if (userRole == 'barber') return '/barber';
        if (userRole == 'client') return '/dash_cliente';
      }

      // 3. Se sei loggato, non hai un ruolo, e cerchi di scappare dalla selezione ruolo, ti blocchiamo
      if (isAuth &&
          userRole == null &&
          state.matchedLocation != '/role-selection') {
        return '/role-selection';
      }

      return null; // Tutto ok, passa pure!
    },

    ///Rotte.
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // -- AREA BARBIERE (B2B) --
      GoRoute(
        path: '/barber',
        builder: (context, state) => const DashboardScreen(),
      ),

      // -- AREA CLIENTE (B2C - Il tuo codice precedente) --
      GoRoute(
        path: '/dash_cliente',
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: '/prenota-orario',
        builder: (context, state) => const SelezioneOrarioScreen(),
      ),
      GoRoute(
        path: '/menu-servizi/:barbiere/:ora/:minuti',
        builder: (context, state) => MenuServiziScreen(
          nomeBarbiere: state.pathParameters['barbiere']!,
          orarioSelezionato: state.pathParameters['ora']!,
        ),
      ),
      GoRoute(
        path: '/riepilogo',
        builder: (context, state) => const RiepilogoPrenotazioneScreen(),
      ),
    ],
  );
});
