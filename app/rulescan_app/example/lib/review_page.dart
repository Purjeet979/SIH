import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'rule_engine.dart';
import 'db_helper.dart';
import 'fact_extractor.dart';
import 'ocr_data.dart';

class ReviewPage extends StatefulWidget {
  final String ocrText;
  final String? imagePath;
  final String? barcode;
  final List<OcrBlock>? ocrBlocks;

  const ReviewPage({super.key, required this.ocrText, this.imagePath, this.barcode, this.ocrBlocks});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final RuleEngine _engine = RuleEngine();
  String _selectedCategory = 'cosmetics_toiletries';
  List<Violation> _violations = [];
  Map<String, dynamic> _facts = {};
  bool _isLoading = true;
  
  // Tap-to-Measure State
  ui.Image? _rawImage;
  Offset? _tap1;
  Offset? _tap2;
  double? _pixelsPerMm = 7.0; // Default estimate for 15cm distance

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
    if (widget.imagePath != null) {
      final bytes = await File(widget.imagePath!).readAsBytes();
      _rawImage = await decodeImageFromList(bytes);
    }
    await _engine.loadRules(_selectedCategory);
    _evaluateRules();
  }

  void _evaluateRules() {
    Map<String, dynamic> facts = FactExtractor.extractFacts(widget.ocrText, widget.ocrBlocks ?? [], pixelsPerMm: _pixelsPerMm);
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
        : SingleChildScrollView(
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
                if (widget.imagePath != null && _rawImage != null)
                  ExpansionTile(
                    title: const Text('Optional: Precise Font Calibration', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Default assumes 15cm photo distance.'),
                    initiallyExpanded: false,
                    children: [ _buildTapToMeasureUI() ],
                  ),
                const SizedBox(height: 16),
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
                  onChanged: (val) async {
                    if (val != null) {
                      _selectedCategory = val;
                      await _engine.loadRules(val);
                      setState(() {
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
                    if (_facts['font_height_mm'] != null && _facts['font_height_mm'] > 0)
                      Chip(
                        label: Text('Font Height: ${_facts['font_height_mm'].toStringAsFixed(2)} mm'),
                        backgroundColor: Colors.purple.shade100,
                      ),
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
                if (_violations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text("All declarations present!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  )
                else
                  ..._violations.map((v) => Card(
                        color: Colors.red.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text("${v.ruleNumber}: ${v.title}"),
                          subtitle: Text(v.description),
                        ),
                      )).toList(),
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

  Widget _buildTapToMeasureUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Tap the two edges of an ID Card (85.6mm)',
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          height: 250,
          decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              double scale = min(constraints.maxWidth / _rawImage!.width, constraints.maxHeight / _rawImage!.height);
              double displayWidth = _rawImage!.width * scale;
              double displayHeight = _rawImage!.height * scale;

              return Center(
                child: GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      Offset rawTap = details.localPosition / scale;
                      if (_tap1 == null) {
                        _tap1 = rawTap;
                      } else if (_tap2 == null) {
                        _tap2 = rawTap;
                        double dx = _tap1!.dx - _tap2!.dx;
                        double dy = _tap1!.dy - _tap2!.dy;
                        double distPixels = sqrt(dx * dx + dy * dy);
                        _pixelsPerMm = distPixels / 85.6;
                        _evaluateRules();
                      } else {
                        _tap1 = rawTap;
                        _tap2 = null;
                        _pixelsPerMm = 7.0; // reset to default
                        _evaluateRules();
                      }
                    });
                  },
                  child: Stack(
                    children: [
                      Image.file(
                        File(widget.imagePath!),
                        width: displayWidth,
                        height: displayHeight,
                        fit: BoxFit.contain,
                      ),
                      if (_tap1 != null)
                        Positioned(
                          left: _tap1!.dx * scale - 5,
                          top: _tap1!.dy * scale - 5,
                          child: const Icon(Icons.circle, size: 10, color: Colors.red),
                        ),
                      if (_tap2 != null)
                        Positioned(
                          left: _tap2!.dx * scale - 5,
                          top: _tap2!.dy * scale - 5,
                          child: const Icon(Icons.circle, size: 10, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_pixelsPerMm != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Calibration set: ${_pixelsPerMm!.toStringAsFixed(1)} px/mm',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )
      ],
    );
  }
}
