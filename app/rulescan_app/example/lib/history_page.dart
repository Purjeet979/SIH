import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'pdf_service.dart';

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
                    final String barcode = item['barcode'] ?? '';
                    final int vCount = violations.isEmpty ? 0 : violations.split(',').length;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: ExpansionTile(
                        leading: Icon(
                          synced == 1 ? Icons.cloud_done : Icons.cloud_off,
                          color: synced == 1 ? Colors.green : Colors.orange,
                          size: 32,
                        ),
                        title: Text('Insp #${item['id']} - ${cat.replaceAll('_', ' ').toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          vCount == 0 ? '✓ Compliant' : '⚠ $vCount Flags',
                          style: TextStyle(color: vCount == 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            color: Colors.grey.shade50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (barcode.isNotEmpty) ...[
                                  Text('Barcode: $barcode', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                ],
                                Text('Date: $time'),
                                const SizedBox(height: 4),
                                Text('GPS: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'),
                                const SizedBox(height: 8),
                                const Text('Violations:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(violations.isEmpty ? "None" : violations.replaceAll(',', '\n')),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                                    label: const Text('Share PDF Report', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueGrey,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    onPressed: () async {
                                      await PdfService.generateAndSharePdf(item);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
