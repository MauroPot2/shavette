import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/prenotazioni/data/mock_barbieri.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/barber_row.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/confirm_sheet.dart';
import 'package:shavette/features/prenotazioni/presentation/widgets/date_strip.dart';

class SelezioneOrarioScreen extends ConsumerStatefulWidget {
  const SelezioneOrarioScreen({super.key});

  @override
  ConsumerState<SelezioneOrarioScreen> createState() =>
      _SelezioneOrarioScreenState();
}

class _SelezioneOrarioScreenState extends ConsumerState<SelezioneOrarioScreen> {
  // Unico stato locale della pagina: il calendario in alto
  int _giornoSelezionatoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(bookingProvider);

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
          DateStrip(
            selectedIndex: _giornoSelezionatoIndex,
            onDaySelected: (index) =>
                setState(() => _giornoSelezionatoIndex = index),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
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
