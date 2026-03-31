import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import delle tue classi
import 'package:shavette/features/auth/data/auth_repository.dart';
import 'package:shavette/features/auth/presentation/screens/login_screen.dart';
import 'package:shavette/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:shavette/features/barbieri/presentation/screens/barber_onboarding_screen.dart';
import 'package:shavette/features/clienti/presentation/screens/client_home_screen.dart';
import 'package:shavette/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/riepilogo_prenotazione_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/presentation/screens/menu_servizi_screen.dart';

/// PROVIDER RUOLO: Legge la "Verità" da Firestore in tempo reale
final userRoleProvider = FutureProvider<String?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;

  // 1. Controlla il ruolo nel documento dell'utente
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  if (!userDoc.exists) return null;

  final role = userDoc.data()?['role'];

  // 2. Se è un cliente, restituiamo subito 'client'
  if (role == 'client') return 'client';

  // 3. Se è un barbiere, verifichiamo se ha completato l'onboarding (salone creato)
  if (role == 'barber') {
    final saloneDoc = await FirebaseFirestore.instance
        .collection('barbieri')
        .doc(user.uid)
        .get();

    return saloneDoc.exists ? 'barber' : 'barber_onboarding';
  }

  return null;
});

/// ROUTER PROVIDER: Il Vigile Urbano dell'app
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final roleState = ref.watch(userRoleProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      // Aspetta che i dati di Firebase siano caricati
      if (authState.isLoading || roleState.isLoading) return null;

      final user = authState.value;
      final role = roleState.value;
      final String location = state.matchedLocation;

      // --- LOGICA DI REINDIRIZZAMENTO ---

      // 1. UTENTE NON LOGGATO: Forza sempre il login
      if (user == null) {
        return location == '/login' ? null : '/login';
      }

      // 2. LOGGATO MA SENZA RUOLO: Forza scelta ruolo
      if (role == null) {
        return location == '/role-selection' ? null : '/role-selection';
      }

      // 3. LOGGATO CON RUOLO: Smistamento basato sulla destinazione
      final bool isAtAuthScreen =
          location == '/login' || location == '/role-selection';

      // CASO: CLIENTE
      if (role == 'client') {
        // Se è in una pagina di auth o prova a entrare nell'area barbiere -> Rimbalza in Dash Cliente
        if (isAtAuthScreen || location.startsWith('/barber')) {
          return '/dash_cliente';
        }
      }

      // CASO: BARBIERE IN ATTESA DI ONBOARDING
      if (role == 'barber_onboarding') {
        if (location != '/barber-onboarding') {
          return '/barber-onboarding';
        }
      }

      // CASO: BARBIERE ATTIVO (Onboarding completato)
      if (role == 'barber') {
        // Se è in una pagina di auth o nella dash del cliente -> Rimbalza in Dash Barbiere
        if (isAtAuthScreen || location == '/dash_cliente') {
          return '/barber';
        }
      }

      // Se è già sulla rotta corretta, non fare nulla
      return null;
    },

    routes: [
      // AREA AUTENTICAZIONE
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // AREA BARBIERE (B2B)
      GoRoute(
        path: '/barber',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/barber-onboarding',
        builder: (context, state) => const BarberOnboardingScreen(),
      ),

      // AREA CLIENTE (B2C)
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
