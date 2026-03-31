import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/prenotazioni/data/mock_barbieri.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/barber_row.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/confirm_sheet.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/date_strip.dart';


final clientSelectedDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

// 2. TRASFORMATO IN CONSUMER WIDGET (Molto più veloce di uno StatefulWidget)
class SelezioneOrarioScreen extends ConsumerWidget {
  const SelezioneOrarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Ascoltiamo i due stati in modo indipendente
    final bookingState = ref.watch(bookingProvider);
    final dataSelezionata = ref.watch(clientSelectedDateProvider);

    final selectedSlotKey =
        (bookingState.barbiereId != null && bookingState.orario != null)
        ? '${bookingState.barbiereId}-${bookingState.orario}'
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text(
          'Scegli Orario',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          // 3. AGGIORNIAMO LA DATE STRIP
          // Nota: dovrai adattare DateStrip per accettare DateTime invece di int
          DateStrip(
            selectedDate: dataSelezionata,
            onDaySelected: (nuovaData) {
              ref.read(clientSelectedDateProvider.notifier).state = nuovaData;
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              // In futuro qui passeremo la dataSelezionata a Firebase per filtrare i barbieri!
              itemCount: barbieriDelGiorno.length,
              itemBuilder: (context, index) {
                return BarberRow(
                  barbiere: barbieriDelGiorno[index],
                  selectedSlotKey: selectedSlotKey,
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: ConfirmSheet(
        barbiereId: bookingState.barbiereId,
        orario: bookingState.orario,
      ),
    );
  }
}
