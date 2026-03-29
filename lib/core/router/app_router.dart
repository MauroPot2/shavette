import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:go_router/go_router.dart';

import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/features/auth/presentation/screens/login_screen.dart';
import 'package:shavette/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:shavette/features/clienti/presentation/screens/client_home_screen.dart';
import 'package:shavette/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/riepilogo_prenotazione_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/presentation/screens/menu_servizi_screen.dart';



/// MOCK: Provider temporaneo per il ruolo finché non lo colleghiamo a Firestore
final userRoleProvider = StateProvider<String?>((ref) => null);

/// Il nostro navigatore di schermate dinamico gestito da Riverpod
final routerProvider = Provider<GoRouter>((ref) {
  // Ascoltiamo lo stato di Firebase (loggato/non loggato)
  final authState = ref.watch(authStateProvider);
  // Ascoltiamo il ruolo (barbiere/cliente/null)
  final userRole = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/login',

    ///Redirect Logic.
    redirect: (context, state) {
      /// Continua a non fare niente se autenticazione still loading.
      if (authState.isLoading) return null;

      final isAuth = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      /// Se non sei loggato vieni reindirizzato alla pagina di login.
      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      /// Se sei loggato in base al tuo stato vieni smistato tra le schermate.
      if (isLoggingIn) {
        if (userRole == null) return '/role-selection';
        if (userRole == 'barber') return '/barber';
        if (userRole == 'client') return '/dash_cliente';
      }

      /// Se sei loggato e non hai un ruolo non puoi fare niente
      ///  se non scegliere un ruolo.
      if (isAuth &&
          userRole == null &&
          state.matchedLocation != '/role-selection') {
        return '/role-selection';
      }

      return null; ///Final check
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

      /// Rotte B2B.
      GoRoute(
        path: '/barber',
        builder: (context, state) => const DashboardScreen(),
      ),

      ///Rotte B2C.
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
