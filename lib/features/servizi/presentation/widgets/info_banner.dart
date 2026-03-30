import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final String nomeBarbiere;
  final String orario;
  final int minutiLiberi;

  const InfoBanner({
    required this.nomeBarbiere,
    required this.orario,
    required this.minutiLiberi,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '''
              Prenotazione con $nomeBarbiere alle $orario.\nSpazio libero: $minutiLiberi min.
              ''',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
