import 'package:go_router/go_router.dart';
import 'package:shavette/features/auth/presentation/screens/login_screen.dart';
import 'package:shavette/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/riepilogo_prenotazione_screen.dart';
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/presentation/screens/menu_servizi_screen.dart';

///Il nostro navigatore di schermate utilizza GO Router.
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // 1. Dashboard (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    // 2. Selezione Orario
    GoRoute(
      path: '/prenota-orario',
      builder: (context, state) => const SelezioneOrarioScreen(),
    ),
    // 3. Menu Servizi
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
