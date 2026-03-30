import 'package:flutter/material.dart';
import 'package:shavette/features/servizi/domain/entities/servizio.dart';

class ServizioCard extends StatelessWidget {
  final Servizio servizio;
  final bool isSelected;
  final bool fitsInSlot;
  final VoidCallback onTap;

  const ServizioCard({
    required this.servizio,
    required this.isSelected,
    required this.fitsInSlot,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servizio.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${servizio.durataMinuti} min',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${servizio.prezzo.toStringAsFixed(0)}€',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!fitsInSlot && !isSelected)
              const Icon(
                Icons.history_toggle_off_rounded,
                color: Colors.orange,
                size: 20,
              )
            else
              Checkbox(
                value: isSelected,
                onChanged: (_) =>
                    onTap(), // Se cliccano la checkbox, fa la stessa cosa del tap sulla card
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
