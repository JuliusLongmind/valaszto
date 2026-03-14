import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/valasztas_service.dart';
import 'home_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedKeruletId;
  final ValasztasService _service = ValasztasService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _service.loadData();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedKeruletId = prefs.getString('selectedKeruletId');
    });
  }

  Future<void> _clearSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedKeruletId');
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beállítások'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader('Választókörzet'),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Kiválasztott körzet'),
            subtitle: Text(_selectedKeruletId ?? 'Nincs kiválasztva'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text(
              'Körzet kiválasztásának törlése',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _showClearConfirmation(),
          ),
          const Divider(),
          const SizedBox(height: 16),
          _buildSectionHeader('Alkalmazás'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Választás 2026'),
            subtitle: Text('Verzió 1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.description_outlined),
            title: Text('Adatforrások'),
            subtitle: Text('2026-valasztas.hu\nvtr.valasztas.hu'),
          ),
          ListTile(
            leading: Icon(
              _service.isUsingRealData ? Icons.cloud_done : Icons.cloud_off,
              color: _service.isUsingRealData ? Colors.green : Colors.orange,
            ),
            title: const Text('Adatállapot'),
            subtitle: Text(
              _service.isUsingRealData
                  ? 'Valós adatok betöltve\n${_service.jeloltek.length} jelölt, ${_service.keruletek.length} körzet'
                  : 'Mock adatok (hiba)',
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          _buildSectionHeader('Fontos információk'),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Figyelem',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Az alkalmazásban megjelenő adatok tájékoztató jellegűek. '
                      'A hivatalos adatokért mindig látogassa meg a '
                      'vtr.valasztas.hu oldalt.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Biztosan törlöd?'),
        content: const Text(
          'A kiválasztott szavazókörzet törlésre kerül. Újra kell majd választanod.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mégse'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _clearSelection();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Törlés'),
          ),
        ],
      ),
    );
  }
}
