import 'package:flutter/material.dart';
import 'rule_engine.dart';
import 'db_helper.dart';

class ReviewPage extends StatefulWidget {
  final String ocrText;

  const ReviewPage({super.key, required this.ocrText});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final RuleEngine _engine = RuleEngine();
  String _selectedCategory = 'cosmetics_toiletries';
  List<Violation> _violations = [];
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
    String text = widget.ocrText.toLowerCase();
    
    // Lazy Mock Fact Extraction based on OCR text (Ponytail mode: simplest regex/match)
    Map<String, dynamic> facts = {
      'category': _selectedCategory,
      'manufacturer_address': text.contains('mfg') || text.contains('manufactured') || text.contains('ltd') || text.length > 50,
      'net_quantity': text.contains('net') || text.contains('ml') || text.contains(' g ') || text.contains('kg'),
      'mrp': text.contains('mrp') || text.contains('rs') || text.contains('₹'),
      'manufacture_date': text.contains('mfg') || text.contains('date') || text.contains('202') || text.contains('pkd'),
      'veg_nonveg_mark': false, // Needs shape detection/vision, defaulting to false for demo
      'consumer_care_contact': text.contains('care') || text.contains('feedback') || text.contains('@'),
      'letter_height_mm': 1.0, // Mocked for now, Phase 2 will implement real CV
      'commodity_name': text.length > 10,
    };

    setState(() {
      _violations = _engine.evaluate(facts);
      _isLoading = false;
    });
  }

  Future<void> _saveAndSync() async {
    // Generate simple comma-separated string for violations
    String violationsJson = _violations.map((v) => v.ruleId).join(",");
    
    await DBHelper.instance.insertInspection(_selectedCategory, violationsJson);
    
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
