import 'package:flutter/material.dart';

class DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oggi = DateTime.now();

    // Generiamo i prossimi 14 giorni, azzerando ore e minuti per sicurezza
    final dateGenerate = List.generate(14, (index) {
      final d = oggi.add(Duration(days: index));
      return DateTime(d.year, d.month, d.day);
    });

    const giorniSettimana = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: dateGenerate.length,
        itemBuilder: (context, index) {
          final data = dateGenerate[index];

          // Assicuriamoci di comparare solo anno, mese e giorno
          final dataSelezionataNormalizzata = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
          );

          final isSelected = data.isAtSameMomentAs(dataSelezionataNormalizzata);
          final nomeGiorno = giorniSettimana[data.weekday - 1];

          return GestureDetector(
            onTap: () => onDaySelected(data),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    nomeGiorno,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.day.toString(),
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
