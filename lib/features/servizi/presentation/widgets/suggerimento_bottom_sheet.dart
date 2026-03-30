import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/core/utils/time_utils.dart';
import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';
import 'package:shavette/features/servizi/domain/entities/servizio.dart';

Future<void> mostraSuggerimentoSpostamento({
  required BuildContext context,
  required WidgetRef ref,
  required Servizio servizio,
  required Barbiere barbiere, // dynamic o Barbiere
  required int minutiLiberiReali,
}) async {
  final theme = Theme.of(context);
  final bookingState = ref.read(bookingProvider);

  final prossimoSlotDisponibile = TimeUtils.trovaProssimoSlotDisponibile(
    slotsDelBarbiere: barbiere.slots,
    orarioSelezionato: bookingState.orario!,
    durataServizioMinuti: servizio.durataMinuti,
  );

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(
            prossimoSlotDisponibile != null
                ? Icons.auto_awesome
                : Icons.error_outline,
            color: prossimoSlotDisponibile != null
                ? Colors.amber
                : Colors.redAccent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            prossimoSlotDisponibile != null
                ? 'Serve più tempo!'
                : 'Giornata Piena!',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            prossimoSlotDisponibile != null
                ? '''
                Il servizio "${servizio.nome}" richiede ${servizio.durataMinuti} minuti, ma alle ${bookingState.orario} abbiamo solo $minutiLiberiReali minuti liberi.
                '''
                : '''
                Purtroppo non ci sono buchi abbastanza grandi per "${servizio.nome}" il resto della giornata.
                ''',
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          if (prossimoSlotDisponibile != null)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ref
                    .read(bookingProvider.notifier)
                    .setOrario(
                      bookingState.barbiereId!,
                      prossimoSlotDisponibile,
                    );
                ref
                    .read(bookingProvider.notifier)
                    .toggleServizio(servizio.id, servizio.durataMinuti);
                Navigator.pop(context);
              },
              child: Text(
                'Sposta alle $prossimoSlotDisponibile',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Scegli un altro servizio'),
          ),
        ],
      ),
    ),
  );
}
