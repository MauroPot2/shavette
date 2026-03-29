import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/providers/booking_provider.dart';
import 'package:shavette/features/barbieri/domain/entities/barbiere.dart';

class BarberRow extends ConsumerWidget {
  final Barbiere barbiere;
  final String? selectedSlotKey;

  const BarberRow({
    super.key,
    required this.barbiere,
    this.selectedSlotKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .2), width: 2),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(barbiere.avatarUrl),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(barbiere.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      barbiere.isAlCompleto ? 'Nessun posto oggi' : 'Posti disponibili',
                      style: TextStyle(fontSize: 12, color: barbiere.isAlCompleto ? Colors.red : Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!barbiere.isAlCompleto)
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: barbiere.slots.length,
              itemBuilder: (context, index) {
                final slot = barbiere.slots[index];
                final key = "${barbiere.id}-${slot.orario}";
                final isSelected = selectedSlotKey == key;

                return GestureDetector(
                  onTap: slot.isOccupato
                      ? null
                      : () => ref.read(bookingProvider.notifier).setOrario(barbiere.id, slot.orario),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected ? theme.colorScheme.primaryContainer : (slot.isOccupato ? Colors.transparent : theme.colorScheme.surface),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot.orario,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.primary : (slot.isOccupato ? Colors.grey[400] : theme.colorScheme.onSurface),
                          decoration: slot.isOccupato ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none, size: 18),
              label: const Text('Avvisami se si libera un posto'),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            ),
          ),
        const SizedBox(height: 10),
        Divider(color: theme.colorScheme.outlineVariant.withValues(alpha: .5)),
      ],
    );
  }
}