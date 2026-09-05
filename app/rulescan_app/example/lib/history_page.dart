import 'package:flutter/material.dart';
import 'db_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final db = await DBHelper.instance.database;
    final records = await db.query('inspections', orderBy: 'id DESC');
    setState(() {
      _inspections = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection History'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inspections.isEmpty
              ? const Center(child: Text('No offline inspections found.'))
              : ListView.builder(
                  itemCount: _inspections.length,
                  itemBuilder: (context, index) {
                    final item = _inspections[index];
                    final String cat = item['category'] ?? 'Unknown';
                    final String time = item['timestamp']?.toString().split('T').first ?? '';
                    final int synced = item['synced'] ?? 0;
                    final double lat = item['latitude'] ?? 0.0;
                    final double lng = item['longitude'] ?? 0.0;
                    final String violations = item['violations'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          synced == 1 ? Icons.cloud_done : Icons.cloud_off,
                          color: synced == 1 ? Colors.green : Colors.orange,
                        ),
                        title: Text(cat.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Date: $time\nGPS: $lat, $lng\nFlags: ${violations.isEmpty ? "None" : violations}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
