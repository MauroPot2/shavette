import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/features/auth/presentation/screens/login_screen.dart';
import 'package:shavette/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:shavette/features/barbieri/presentation/screens/barber_onboarding_screen.dart';
import 'package:shavette/features/clienti/presentation/screens/client_home_screen.dart';
import 'package:shavette/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/riepilogo_prenotazione_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/presentation/screens/menu_servizi_screen.dart';

/// NUOVO: Provider intelligente che legge la verità da Firebase!
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  // 1. Controlla il ruolo scelto dal documento in 'users'
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  if (!userDoc.exists) return null;

  final role = userDoc.data()?['role'];

  if (role == 'client') return 'client';

  if (role == 'barber') {
    // 2. Controllo fondamentale: ha già compilato il form Onboarding?
    final saloneDoc = await FirebaseFirestore.instance
        .collection('barbieri')
        .doc(user.uid)
        .get();

    // Se il documento del salone esiste, salta l'onboarding. Altrimenti ci deve passare.
    return saloneDoc.exists ? 'barber' : 'barber_onboarding';
  }

  return null;
});

/// Il navigatore dinamico
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final roleState = ref.watch(userRoleProvider); // Ora è un AsyncValue

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      // Se sta ancora contattando Firebase, aspetta
      if (authState.isLoading || roleState.isLoading) return null;

      final isAuth = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuth) {
        return isLoggingIn ? null : '/login';
      }

      final userRole = roleState.value;

      // Smistamento dalla pagina di login in base ai dati di Firebase
      if (isLoggingIn) {
        if (userRole == null) return '/role-selection';
        if (userRole == 'barber_onboarding') return '/barber-onboarding';
        if (userRole == 'barber') return '/barber';
        if (userRole == 'client') return '/dash_cliente';
      }

      if (isAuth &&
          userRole == null &&
          state.matchedLocation != '/role-selection') {
        return '/role-selection';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/barber',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/barber-onboarding',
        builder: (context, state) => const BarberOnboardingScreen(),
      ),
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
