import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shavette/core/router/app_router.dart';
import 'package:shavette/features/barbieri/data/barbieri_repository.dart';

class BarberOnboardingScreen extends ConsumerStatefulWidget {
  const BarberOnboardingScreen({super.key});

  @override
  ConsumerState<BarberOnboardingScreen> createState() =>
      _BarberOnboardingScreenState();
}

class _BarberOnboardingScreenState extends ConsumerState<BarberOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 1. CONTROLLERS ANAGRAFICA
  final _nomeController = TextEditingController();
  final _pivaController = TextEditingController();
  final _telefonoController = TextEditingController();

  // 2. CONTROLLERS INDIRIZZO
  final _viaController = TextEditingController();
  final _civicoController = TextEditingController();
  final _cittaController = TextEditingController();
  final _capController = TextEditingController();

  // 3. GESTIONE STAFF
  final _staffNomeController = TextEditingController();
  final List<String> _collaboratori = [];

  // 4. BRAND IDENTITY
  Color _selectedColor = Colors.blue;
  final List<Color> _coloriDisponibili = [
    Colors.blue, Colors.red, Colors.green, 
    Colors.orange, Colors.purple, Colors.black, Colors.teal
  ];

  bool _isLoading = false;

  void _aggiungiCollaboratore() {
    final nome = _staffNomeController.text.trim();
    if (nome.isNotEmpty && !_collaboratori.contains(nome)) {
      setState(() {
        _collaboratori.add(nome);
        _staffNomeController.clear();
      });
    }
  }

  void _rimuoviCollaboratore(String nome) {
    setState(() {
      _collaboratori.remove(nome);
    });
  }

  Future<void> _salvaSalone() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validazione personalizzata: almeno un barbiere (il titolare)
    if (_collaboratori.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aggiungi almeno un collaboratore (es. te stesso)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utente non loggato');

      // Impacchettiamo l'indirizzo
      final indirizzoCompleto = {
        'via': _viaController.text.trim(),
        'civico': _civicoController.text.trim(),
        'citta': _cittaController.text.trim(),
        'cap': _capController.text.trim(),
      };

      // Nota: Dovremo aggiornare BarbieriRepository per accettare questi nuovi campi!
      await ref.read(barbieriRepositoryProvider).creaSalone(
            uid: user.uid,
            nomeSalone: _nomeController.text.trim(),
            piva: _pivaController.text.trim(),
            telefono: _telefonoController.text.trim(),
            indirizzo: indirizzoCompleto,
            coloreBrand: _selectedColor.value.toRadixString(16), // Salviamo il colore come stringa HEX
            staff: _collaboratori,
          );

      // Aggiorniamo il router
      ref.read(userRoleProvider.notifier).state = 'barber';
      
    } catch (e) {
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
    _pivaController.dispose();
    _telefonoController.dispose();
    _viaController.dispose();
    _civicoController.dispose();
    _cittaController.dispose();
    _capController.dispose();
    _staffNomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configura il tuo Salone')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Benvenuto! Configura la tua vetrina per i clienti.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- SEZIONE 1: ANAGRAFICA ---
            _buildSectionTitle(Icons.storefront, 'Info Salone'),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome del Salone'),
              validator: (v) => v!.isEmpty ? 'Inserisci il nome' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(labelText: 'Telefono'),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Richiesto' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _pivaController,
                    decoration: const InputDecoration(labelText: 'P.IVA (Opzionale)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- SEZIONE 2: INDIRIZZO ---
            _buildSectionTitle(Icons.location_on, 'Indirizzo'),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _viaController,
                    decoration: const InputDecoration(labelText: 'Via/Piazza'),
                    validator: (v) => v!.isEmpty ? 'Richiesto' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _civicoController,
                    decoration: const InputDecoration(labelText: 'N°'),
                    validator: (v) => v!.isEmpty ? '!' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cittaController,
                    decoration: const InputDecoration(labelText: 'Città'),
                    validator: (v) => v!.isEmpty ? 'Richiesto' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _capController,
                    decoration: const InputDecoration(labelText: 'CAP'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? '!' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // --- SEZIONE 3: STAFF ---
            _buildSectionTitle(Icons.people, 'Staff e Collaboratori'),
            const Text('Aggiungi i barbieri che lavorano nel salone per creare i loro calendari.'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _staffNomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Collaboratore',
                      hintText: 'Es. Marco',
                    ),
                    onFieldSubmitted: (_) => _aggiungiCollaboratore(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 32, color: Colors.blue),
                  onPressed: _aggiungiCollaboratore,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _collaboratori.map((nome) {
                return Chip(
                  label: Text(nome),
                  onDeleted: () => _rimuoviCollaboratore(nome),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // --- SEZIONE 4: BRAND IDENTITY ---
            _buildSectionTitle(Icons.palette, 'Personalizzazione'),
            const Text('Scegli il colore principale della tua vetrina:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _coloriDisponibili.map((colore) {
                final isSelected = _selectedColor == colore;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colore),
                  child: CircleAvatar(
                    backgroundColor: colore,
                    radius: isSelected ? 24 : 18,
                    child: isSelected 
                        ? const Icon(Icons.check, color: Colors.white) 
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prossimamente: Caricamento Logo!')),
                );
              },
              icon: const Icon(Icons.image),
              label: const Text('Carica Logo del Salone'),
            ),
            const SizedBox(height: 48),

            // --- TASTO SALVATAGGIO ---
            ElevatedButton(
              onPressed: _isLoading ? null : _salvaSalone,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Salva e vai alla Dashboard',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget helper per i titoli delle sezioni
  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}