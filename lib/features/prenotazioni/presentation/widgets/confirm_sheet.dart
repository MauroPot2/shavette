import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Importiamo il provider dei dati reali
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';

class ConfirmSheet extends ConsumerWidget {
  const ConfirmSheet({
    required this.barbiereId,
    required this.orario,
    super.key,
  });

  final String? barbiereId;
  final String? orario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Se non c'è nulla di selezionato, non mostriamo nulla (SizedBox vuoto)
    if (barbiereId == null || orario == null) return const SizedBox.shrink();

    // 2. Leggiamo i barbieri reali da Firebase tramite il provider
    final staffAsync = ref.watch(staffSaloneProvider);

    return staffAsync.when(
      loading: () => const SizedBox.shrink(), // Nascondi durante il caricamento
      error: (_, __) => const SizedBox.shrink(), // Nascondi in caso di errore
      data: (listaBarbieri) {
        // 3. Cerchiamo il barbiere reale. 
        // Usiamo orElse per evitare il "Bad state: No element"
        final barbiere = listaBarbieri.firstWhere(
          (b) => b.id == barbiereId,
          orElse: () => listaBarbieri.first, 
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prenotazione con ${barbiere.nome}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Orario: $orario',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Navighiamo verso il menu servizi passando i dati
                    context.push('/menu-servizi/${barbiere.nome}/$orario/0');
                  },
                  child: const Text('Continua'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}