import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shavette/core/router/app_router.dart';
import 'package:shavette/features/barbieri/data/barbieri_repository.dart';

class BarberOnboardingScreen extends ConsumerStatefulWidget {
  const BarberOnboardingScreen({super.key});

  @override
  ConsumerState<BarberOnboardingScreen> createState() =>
      _BarberOnboardingScreenState();
}

class _BarberOnboardingScreenState
    extends ConsumerState<BarberOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _indirizzoController = TextEditingController();

  bool _isLoading = false;

  Future<void> _salvaSalone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Recuperiamo l'utente attualmente loggato (da Firebase Auth)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utente non loggato');

      // Chiamiamo il nostro Repository per salvare su Firestore
      await ref
          .read(barbieriRepositoryProvider)
          .creaSalone(
            uid: user.uid,
            nomeSalone: _nomeController.text.trim(),
            indirizzo: _indirizzoController.text.trim(),
          );

      // Se tutto va bene, lo mandiamo alla sua Dashboard!
      ref.read(userRoleProvider.notifier).state = 'barber';
      
    } catch (e) {
      // Mostriamo un errore se qualcosa va storto
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _indirizzoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configura il tuo Salone')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Benvenuto! Inserisci i dati principali della tua attività.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),

              // CAMPO NOME
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome del Salone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Inserisci il nome' : null,
              ),
              const SizedBox(height: 16),

              // CAMPO INDIRIZZO
              TextFormField(
                controller: _indirizzoController,
                decoration: const InputDecoration(
                  labelText: 'Indirizzo completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Inserisci l'indirizzo"
                    : null,
              ),
              const SizedBox(height: 32),

              // BOTTONE SALVATAGGIO
              ElevatedButton(
                onPressed: _isLoading ? null : _salvaSalone,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Salva e vai alla Dashboard',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
