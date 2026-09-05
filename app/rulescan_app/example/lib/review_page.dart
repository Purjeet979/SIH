import 'package:flutter/material.dart';
import 'rule_engine.dart';
import 'db_helper.dart';
import 'fact_extractor.dart';
class ReviewPage extends StatefulWidget {
  final String ocrText;
  final String? imagePath;
  final String? barcode;

  const ReviewPage({super.key, required this.ocrText, this.imagePath, this.barcode});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final RuleEngine _engine = RuleEngine();
  String _selectedCategory = 'cosmetics_toiletries';
  List<Violation> _violations = [];
  Map<String, dynamic> _facts = {};
  bool _isLoading = true;

  final List<String> _categories = [
    'packaged_food',
    'cosmetics_toiletries',
    'cement_construction',
    'paints_varnishes',
    'textiles_garments',
    'electricals_wire',
    'lpg_cylinders',
    'chemicals_liquids',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  Future<void> _initEngine() async {
    await _engine.loadRules();
    _evaluateRules();
  }

  void _evaluateRules() {
    Map<String, dynamic> facts = FactExtractor.extractFacts(widget.ocrText);
    facts['category'] = _selectedCategory; // Override with user selection

    setState(() {
      _facts = facts;
      _violations = _engine.evaluate(facts);
      _isLoading = false;
    });
  }

  Future<void> _saveAndSync() async {
    // Generate simple comma-separated string for violations
    String violationsJson = _violations.map((v) => v.ruleId).join(",");
    
    await DBHelper.instance.insertInspection(_selectedCategory, violationsJson, imagePath: widget.imagePath, barcode: widget.barcode);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspection saved locally (with Geotag). Ready for sync.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Inspection'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.barcode != null && widget.barcode!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Chip(
                      label: Text('Barcode ID: ${widget.barcode}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.blue.shade100,
                      avatar: const Icon(Icons.qr_code_scanner),
                    ),
                  ),
                const Text(
                  'Extracted Text (OCR)', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: SingleChildScrollView(
                    child: Text(widget.ocrText.isEmpty ? "No text detected" : widget.ocrText),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Commodity Category', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  items: _categories.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCategory = val;
                        _evaluateRules();
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Extracted Values', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    if (_facts['mrp_value'] != null) Chip(label: Text('MRP: ${_facts['mrp_value']}'), backgroundColor: Colors.green.shade100),
                    if (_facts['net_quantity_value'] != null) Chip(label: Text('Qty: ${_facts['net_quantity_value']}'), backgroundColor: Colors.blue.shade100),
                    if (_facts['manufacture_date_value'] != null) Chip(label: Text('Mfg: ${_facts['manufacture_date_value']}'), backgroundColor: Colors.orange.shade100),
                    if (_facts['best_before_or_use_by_value'] != null) Chip(label: Text('Exp: ${_facts['best_before_or_use_by_value']}'), backgroundColor: Colors.red.shade100),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rule Engine Results', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    Chip(
                      label: Text(
                        _violations.isEmpty ? 'Compliant' : '${_violations.length} Flags',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                      backgroundColor: _violations.isEmpty ? Colors.green : Colors.red,
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _violations.isEmpty
                    ? const Center(child: Text("All declarations present!"))
                    : ListView.builder(
                        itemCount: _violations.length,
                        itemBuilder: (context, index) {
                          final v = _violations[index];
                          return Card(
                            color: Colors.red.shade50,
                            child: ListTile(
                              leading: const Icon(Icons.warning, color: Colors.red),
                              title: Text("${v.ruleNumber}: ${v.title}"),
                              subtitle: Text(v.description),
                            ),
                          );
                        },
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(vertical: 16)
                  ),
                  onPressed: _saveAndSync,
                  child: const Text('CONFIRM & SAVE INSPECTION', style: TextStyle(fontSize: 16, color: Colors.white)),
                )
              ],
            ),
          ),
    );
  }
}
