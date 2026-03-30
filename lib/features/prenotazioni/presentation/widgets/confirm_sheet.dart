import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shavette/features/prenotazioni/data/mock_barbieri.dart';

class ConfirmSheet extends StatelessWidget {
  final String? barbiereId;
  final String? orario;

  const ConfirmSheet({
    required this.barbiereId,
    required this.orario,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (barbiereId == null || orario == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final barbiere = barbieriDelGiorno.firstWhere((b) => b.id == barbiereId);

    /// Lo passiamo solo per assecondare il Router,
    ///  la prossima schermata non lo userà!
    const minutiLiberi = 45;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () async {
          await context.push('/menu-servizi/${barbiere.nome}/$orario/$minutiLiberi');
        },
        child: const Text(
          'Conferma Orario',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
