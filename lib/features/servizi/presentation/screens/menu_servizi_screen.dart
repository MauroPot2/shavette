import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/core/utils/time_utils.dart';
import 'package:shavette/features/prenotazioni/data/mock_barbieri.dart';
import 'package:shavette/features/servizi/data/mock_servizi.dart';

import 'package:shavette/features/servizi/presentation/widgets/info_banner.dart';
import 'package:shavette/features/servizi/presentation/widgets/servizio_card.dart';
import 'package:shavette/features/servizi/presentation/widgets/suggerimento_bottom_sheet.dart';
import 'package:shavette/features/servizi/presentation/widgets/summary_bottom_bar.dart';

///classe della pagina menu servizi
class MenuServiziScreen extends ConsumerWidget {
  ///costruttore della pagina menu servizi
  const MenuServiziScreen({
    super.key,
    required this.nomeBarbiere,
    this.orarioSelezionato = '10:00',
  });

  /// nome barbiere.
  final String nomeBarbiere;

  /// orario selezionato.
  final String orarioSelezionato;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(bookingProvider);

    final barbiere = barbieriDelGiorno.firstWhere(
      (b) => b.id == bookingState.barbiereId,
    );

    // 1. Logica delegata
    final minutiLiberiReali = TimeUtils.calcolaMinutiLiberiReali(
      slotsDelBarbiere: barbiere.slots,
      orario: bookingState.orario,
    );

    final selezionati = listaServizi
        .where((s) => bookingState.serviziIds.contains(s.id))
        .toList();
    final totalePrezzo = selezionati.fold<double>(
      0,
      (sum, item) => sum + item.prezzo,
    );

    // 2. UI Dichiarativa
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Seleziona Servizi',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          InfoBanner(
            nomeBarbiere: nomeBarbiere,
            orario: bookingState.orario ?? orarioSelezionato,
            minutiLiberi: minutiLiberiReali,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              itemCount: listaServizi.length,
              itemBuilder: (context, index) {
                final servizio = listaServizi[index];
                final isSelected = bookingState.serviziIds.contains(
                  servizio.id,
                );
                final fitsInSlot =
                    (bookingState.minutiTotali + servizio.durataMinuti) <=
                    minutiLiberiReali;

                return ServizioCard(
                  servizio: servizio,
                  isSelected: isSelected,
                  fitsInSlot: fitsInSlot,
                  onTap: () async {
                    if (isSelected || fitsInSlot) {
                      ref
                          .read(bookingProvider.notifier)
                          .toggleServizio(servizio.id, servizio.durataMinuti);
                    } else {
                      await mostraSuggerimentoSpostamento(
                        context: context,
                        ref: ref,
                        servizio: servizio,
                        barbiere: barbiere,
                        minutiLiberiReali: minutiLiberiReali,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: SummaryBottomBar(
        prezzo: totalePrezzo,
        tempo: bookingState.minutiTotali,
        onContinue: () => context.push('/riepilogo'),
      ),
    );
  }
}
