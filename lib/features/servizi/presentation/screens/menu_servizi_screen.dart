import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/core/utils/time_utils.dart';
// Importiamo il provider corretto che legge da Firebase
import 'package:shavette/features/prenotazioni/presentation/screens/selezione_orario_screen.dart';
import 'package:shavette/features/servizi/data/mock_servizi.dart';

import 'package:shavette/features/servizi/presentation/widgets/info_banner.dart';
import 'package:shavette/features/servizi/presentation/widgets/servizio_card.dart';
import 'package:shavette/features/servizi/presentation/widgets/suggerimento_bottom_sheet.dart';
import 'package:shavette/features/servizi/presentation/widgets/summary_bottom_bar.dart';

import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';

class MenuServiziScreen extends ConsumerWidget {
  const MenuServiziScreen({
    required this.nomeBarbiere,
    this.orarioSelezionato = '10:00',
    super.key,
  });

  final String nomeBarbiere;
  final String orarioSelezionato;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingState = ref.watch(bookingProvider);
    
    // 1. ASCOLTIAMO I DATI REALI DA FIREBASE
    final staffAsync = ref.watch(staffSaloneProvider);

    return staffAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Errore nel caricamento: $err')),
      ),
      data: (listaBarbieriReali) {
        // 2. CERCHIAMO IL BARBIERE SELEZIONATO NELLA LISTA REALE
        // Usiamo orElse per evitare il crash "Bad State: No element"
        final Barbiere barbiere = listaBarbieriReali.firstWhere(
          (b) => b.id == bookingState.barbiereId,
          orElse: () => listaBarbieriReali.first,
        );

        // 3. LOGICA DEI MINUTI LIBERI
        final int minutiLiberiReali = TimeUtils.calcolaMinutiLiberiReali(
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
                nomeBarbiere: barbiere.nome, // Nome reale da DB
                orario: bookingState.orario ?? orarioSelezionato,
                minutiLiberi: minutiLiberiReali,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                  itemCount: listaServizi.length,
                  itemBuilder: (context, index) {
                    final servizio = listaServizi[index];
                    final isSelected = bookingState.serviziIds.contains(servizio.id);
                    
                    // Verifichiamo se il servizio entra nello spazio rimasto
                    final fitsInSlot = (bookingState.minutiTotali + servizio.durataMinuti) <= minutiLiberiReali;

                    return ServizioCard(
                      servizio: servizio,
                      isSelected: isSelected,
                      fitsInSlot: fitsInSlot,
                      onTap: () async {
                        if (isSelected || fitsInSlot) {
                          ref.read(bookingProvider.notifier).toggleServizio(servizio.id, servizio.durataMinuti);
                        } else {
                          // Se non entra, mostriamo il suggerimento per cambiare orario
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
      },
    );
  }
}
