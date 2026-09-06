import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'pdf_service.dart';
import 'theme.dart';

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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inspections.isEmpty
              ? const Center(child: Text('No offline inspections found.'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: synced == 1 ? AppTheme.passGreenLight : AppTheme.pendingAmberLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              synced == 1 ? Icons.cloud_done : Icons.cloud_upload,
                              color: synced == 1 ? AppTheme.passGreen : AppTheme.pendingAmber,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            'Insp #${item['id']} - ${cat.replaceAll('_', ' ').toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: vCount == 0 ? AppTheme.passGreenLight : AppTheme.violationRedLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      vCount == 0 ? Icons.check_circle : Icons.error,
                                      color: vCount == 0 ? AppTheme.passGreen : AppTheme.violationRed,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      vCount == 0 ? 'Compliant' : '$vCount Violations',
                                      style: TextStyle(
                                        color: vCount == 0 ? AppTheme.passGreenText : AppTheme.violationRedText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: AppTheme.surfaceSubtle,
                                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (barcode.isNotEmpty) ...[
                                    Text('Barcode: $barcode', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 8),
                                  ],
                                  Text('Date: $time', style: const TextStyle(color: AppTheme.textSecondary)),
                                  const SizedBox(height: 4),
                                  Text('GPS: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}', style: const TextStyle(color: AppTheme.textSecondary)),
                                  const SizedBox(height: 12),
                                  if (vCount > 0) ...[
                                    const Text('Violations:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                    const SizedBox(height: 4),
                                    Text(violations.replaceAll(',', '\n'), style: const TextStyle(color: AppTheme.violationRedText)),
                                  ],
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                                      label: const Text('Share PDF Report'),
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
                      ),
                    );
                  },
                ),
    );
  }
}
