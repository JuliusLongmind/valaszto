import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/jelolt.dart';
import '../models/valasztokerulet.dart';
import '../services/valasztas_service.dart';
import '../widgets/candidate_card.dart';
import 'candidate_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValasztasService _service = ValasztasService();
  bool _isLoading = true;
  String? _selectedKeruletId;
  List<Jelolt> _jeloltek = [];
  Valasztokerulet? _selectedKerulet;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _service.loadData();
    final prefs = await SharedPreferences.getInstance();
    _selectedKeruletId = prefs.getString('selectedKeruletId');

    if (_selectedKeruletId != null) {
      _selectedKerulet = _service.keruletek.firstWhere(
        (k) => k.id == _selectedKeruletId,
        orElse: () => _service.keruletek.first,
      );
      _jeloltek = _service.getJeloltekByKerulet(_selectedKeruletId!);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectKerulet() async {
    final result = await showModalBottomSheet<Valasztokerulet>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => KeruletSelectorSheet(
        service: _service,
        selectedKeruletId: _selectedKeruletId,
      ),
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedKeruletId', result.id);

      setState(() {
        _selectedKeruletId = result.id;
        _selectedKerulet = result;
        _jeloltek = _service.getJeloltekByKerulet(result.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Választás 2026'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedKeruletId == null
          ? _buildSelectKeruletPrompt()
          : _buildContent(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectKerulet,
        icon: const Icon(Icons.location_on),
        label: Text(_selectedKerulet?.nev.split(',')[0] ?? 'Körzet választás'),
      ),
    );
  }

  Widget _buildSelectKeruletPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.how_to_vote,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Válaszd ki a szavazókörzetedet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Ahhoz, hogy lásd a jelölteket, először ki kell választanod, melyik választókerületben szavazol.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _selectKerulet,
              icon: const Icon(Icons.location_on),
              label: const Text('Körzet kiválasztása'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedKerulet?.nev ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '${_jeloltek.length} jelölt',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Expanded(
          child: _jeloltek.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('Nincs jelölt ebben a körzetben'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _selectKerulet,
                        child: const Text('Másik körzet'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _jeloltek.length,
                  itemBuilder: (context, index) {
                    final jelolt = _jeloltek[index];
                    return CandidateCard(
                      jelolt: jelolt,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CandidateDetailScreen(jelolt: jelolt),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class KeruletSelectorSheet extends StatefulWidget {
  final ValasztasService service;
  final String? selectedKeruletId;

  const KeruletSelectorSheet({
    super.key,
    required this.service,
    this.selectedKeruletId,
  });

  @override
  State<KeruletSelectorSheet> createState() => _KeruletSelectorSheetState();
}

class _KeruletSelectorSheetState extends State<KeruletSelectorSheet> {
  String? _selectedMegye;
  List<Valasztokerulet> _filteredKeruletek = [];

  @override
  void initState() {
    super.initState();
    if (_selectedMegye != null) {
      _filteredKeruletek = widget.service.getKeruletekByMegye(_selectedMegye!);
    }
  }

  void _onMegyeSelected(String megye) {
    setState(() {
      _selectedMegye = megye;
      _filteredKeruletek = widget.service.getKeruletekByMegye(megye);
    });
  }

  @override
  Widget build(BuildContext context) {
    final megyek = widget.service.Megyek;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Választókörzet kiválasztása',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            if (_selectedMegye == null)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: megyek.length,
                  itemBuilder: (context, index) {
                    final megye = megyek[index];
                    return ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text(megye),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _onMegyeSelected(megye),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.arrow_back),
                      title: Text(_selectedMegye!),
                      onTap: () {
                        setState(() {
                          _selectedMegye = null;
                          _filteredKeruletek = [];
                        });
                      },
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredKeruletek.length,
                        itemBuilder: (context, index) {
                          final kerulet = _filteredKeruletek[index];
                          final isSelected =
                              kerulet.id == widget.selectedKeruletId;
                          return ListTile(
                            title: Text(kerulet.nev),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                            selected: isSelected,
                            onTap: () => Navigator.pop(context, kerulet),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
