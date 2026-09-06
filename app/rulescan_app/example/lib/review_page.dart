import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'rule_engine.dart';
import 'db_helper.dart';
import 'fact_extractor.dart';
import 'ocr_data.dart';
import 'theme.dart';

class ReviewPage extends StatefulWidget {
  final String ocrText;
  final String? imagePath;
  final String? barcode;
  final List<OcrBlock>? ocrBlocks;

  const ReviewPage({
    super.key,
    required this.ocrText,
    this.imagePath,
    this.barcode,
    this.ocrBlocks,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final RuleEngine _engine = RuleEngine();
  String _selectedCategory = 'cosmetics_toiletries';
  List<Violation> _violations = [];
  Map<String, dynamic> _facts = {};
  bool _isLoading = true;
  bool _isSaving = false;

  // Dropdown / Accordion state
  bool _isRulesExpanded = true;
  bool _isInfoExpanded = false;
  bool _isCalibrationExpanded = false;

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

  final Map<String, String> _categoryLabels = {
    'packaged_food': 'Packaged Food',
    'cosmetics_toiletries': 'Cosmetics & Toiletries',
    'cement_construction': 'Cement & Construction',
    'paints_varnishes': 'Paints & Varnishes',
    'textiles_garments': 'Textiles & Garments',
    'electricals_wire': 'Electricals & Wires',
    'lpg_cylinders': 'LPG Cylinders',
    'chemicals_liquids': 'Chemicals & Liquids',
    'other': 'General / Other',
  };

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
    Map<String, dynamic> facts = FactExtractor.extractFacts(
      widget.ocrText,
      widget.ocrBlocks ?? [],
      pixelsPerMm: _pixelsPerMm,
    );
    facts['category'] = _selectedCategory;

    setState(() {
      _facts = facts;
      _violations = _engine.evaluate(facts);
      _isLoading = false;
      // Auto-expand rules if there are violations
      _isRulesExpanded = _violations.isNotEmpty;
    });
  }

  Future<void> _saveAndSync() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    String violationsJson = _violations.map((v) => v.ruleId).join(",");

    await DBHelper.instance.insertInspection(
      _selectedCategory,
      violationsJson,
      imagePath: widget.imagePath,
      barcode: widget.barcode,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inspection saved locally with Geotag. Ready for sync.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.passGreenText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBase,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review Inspection',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppTheme.borderSubtle, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Barcode Chip (if present)
                  if (widget.barcode != null && widget.barcode!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlueLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.qr_code_2, color: AppTheme.primaryBlue, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BARCODE IDENTIFIER',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryBlue,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  widget.barcode!,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Verified',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 2. Commodity Category Selector Card
                  _buildCategoryCard(),
                  const SizedBox(height: 16),

                  // 3. Rule Engine Results (Collapsible Accordion / Dropdown)
                  _buildRuleEngineDropdown(),
                  const SizedBox(height: 16),

                  // 4. Extracted Package Info / OCR Text (Collapsible Accordion / Dropdown)
                  _buildExtractedInfoDropdown(),
                  const SizedBox(height: 16),

                  // 5. Optional: Precise Font Calibration (Collapsible Dropdown)
                  if (widget.imagePath != null && _rawImage != null) ...[
                    _buildCalibrationDropdown(),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 12),

                  // 6. Action Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveAndSync,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'CONFIRM & SAVE INSPECTION',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }

  // --- Category Selector Card ---
  Widget _buildCategoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'COMMODITY CATEGORY',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedCategory,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                items: _categories.map((String cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(
                      _categoryLabels[cat] ?? cat.replaceAll('_', ' ').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) async {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      _isLoading = true;
                    });
                    await _engine.loadRules(val);
                    _evaluateRules();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Rule Engine Results Dropdown Card ---
  Widget _buildRuleEngineDropdown() {
    final bool hasViolations = _violations.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasViolations
              ? AppTheme.violationRed.withValues(alpha: 0.35)
              : AppTheme.passGreen.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (hasViolations ? AppTheme.violationRed : AppTheme.passGreen).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Tappable Dropdown Trigger)
          InkWell(
            onTap: () {
              setState(() => _isRulesExpanded = !_isRulesExpanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasViolations
                    ? AppTheme.violationRedLight.withValues(alpha: 0.4)
                    : AppTheme.passGreenLight.withValues(alpha: 0.4),
                borderRadius: _isRulesExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(15))
                    : BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: hasViolations ? AppTheme.violationRedLight : AppTheme.passGreenLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (hasViolations ? AppTheme.violationRed : AppTheme.passGreen).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      hasViolations ? Icons.warning_amber_rounded : Icons.verified,
                      color: hasViolations ? AppTheme.violationRed : AppTheme.passGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rule Engine Results',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasViolations
                              ? '${_violations.length} non-compliance flag(s)'
                              : 'All statutory rules satisfied',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: hasViolations ? AppTheme.violationRedText : AppTheme.passGreenText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasViolations ? AppTheme.violationRed : AppTheme.passGreen,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      hasViolations ? '${_violations.length} Flags' : 'Compliant',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _isRulesExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dropdown Body Content
          if (_isRulesExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasViolations) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.passGreenLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.passGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.passGreen, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'All mandatory declarations (MRP, Net Quantity, Dates, Font Height) comply with Legal Metrology Rules, 2011.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.passGreenText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'MANDATORY DECLARATIONS VIOLATED',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.violationRedText,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._violations.map((v) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.violationRed.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.violationRedLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  color: AppTheme.violationRed,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.violationRedLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            v.ruleNumber,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.violationRedText,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            v.title,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      v.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // --- Extracted Package Info & OCR Dropdown Card ---
  Widget _buildExtractedInfoDropdown() {
    int detectedCount = _facts.values.where((v) => v != null && v.toString().isNotEmpty && v != 0).length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Tappable Dropdown Trigger)
          InkWell(
            onTap: () {
              setState(() => _isInfoExpanded = !_isInfoExpanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isInfoExpanded ? AppTheme.surfaceSubtle.withValues(alpha: 0.5) : Colors.transparent,
                borderRadius: _isInfoExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(15))
                    : BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlueLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(
                      Icons.document_scanner_outlined,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Extracted Package Data (OCR)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$detectedCount declarations identified',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Text(
                      _isInfoExpanded ? 'Hide' : 'Show',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _isInfoExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dropdown Body Content
          if (_isInfoExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Extracted Values Chips
                  Text(
                    'DETECTED DECLARATIONS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if (_facts['mrp_value'] != null)
                        _buildDataChip(
                          icon: Icons.currency_rupee,
                          label: 'MRP: ${_facts['mrp_value']}',
                          color: AppTheme.passGreenText,
                          bgColor: AppTheme.passGreenLight,
                        ),
                      if (_facts['net_quantity_value'] != null)
                        _buildDataChip(
                          icon: Icons.scale_outlined,
                          label: 'Qty: ${_facts['net_quantity_value']}',
                          color: AppTheme.primaryBlue,
                          bgColor: AppTheme.primaryBlueLight,
                        ),
                      if (_facts['manufacture_date_value'] != null)
                        _buildDataChip(
                          icon: Icons.calendar_today_outlined,
                          label: 'Mfg: ${_facts['manufacture_date_value']}',
                          color: AppTheme.pendingAmberText,
                          bgColor: AppTheme.pendingAmberLight,
                        ),
                      if (_facts['best_before_or_use_by_value'] != null)
                        _buildDataChip(
                          icon: Icons.event_busy_outlined,
                          label: 'Exp: ${_facts['best_before_or_use_by_value']}',
                          color: AppTheme.violationRedText,
                          bgColor: AppTheme.violationRedLight,
                        ),
                      if (_facts['font_height_mm'] != null && _facts['font_height_mm'] > 0)
                        _buildDataChip(
                          icon: Icons.format_size,
                          label: 'Font: ${_facts['font_height_mm'].toStringAsFixed(2)} mm',
                          color: const Color(0xFF6D28D9),
                          bgColor: const Color(0xFFEDE9FE),
                        ),
                      if (detectedCount == 0)
                        Text(
                          'No structured declarations identified from OCR text.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 2. Raw OCR Text
                  Text(
                    'RAW OCR EXTRACTED TEXT',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceSubtle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.ocrText.isEmpty ? "No text detected by ML Kit" : widget.ocrText,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- Font Calibration Dropdown Card ---
  Widget _buildCalibrationDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (Tappable Dropdown Trigger)
          InkWell(
            onTap: () {
              setState(() => _isCalibrationExpanded = !_isCalibrationExpanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCalibrationExpanded ? AppTheme.surfaceSubtle.withValues(alpha: 0.5) : Colors.transparent,
                borderRadius: _isCalibrationExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(15))
                    : BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD8B4FE)),
                    ),
                    child: const Icon(
                      Icons.straighten,
                      color: Color(0xFF7C3AED),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precise Font Calibration',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _pixelsPerMm != null
                              ? 'Calibrated: ${_pixelsPerMm!.toStringAsFixed(1)} px/mm'
                              : 'Tap ID card edges (85.6mm) to calibrate',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isCalibrationExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dropdown Body Content
          if (_isCalibrationExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildTapToMeasureUI(),
            ),
        ],
      ),
    );
  }

  Widget _buildTapToMeasureUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Text(
            'Tap the two opposite edges of a standard ID card (85.6mm) in the photo to calibrate physical font dimensions.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double scale = min(
                  constraints.maxWidth / _rawImage!.width,
                  constraints.maxHeight / _rawImage!.height,
                );
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
                            left: _tap1!.dx * scale - 6,
                            top: _tap1!.dy * scale - 6,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.violationRed,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        if (_tap2 != null)
                          Positioned(
                            left: _tap2!.dx * scale - 6,
                            top: _tap2!.dy * scale - 6,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.passGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_pixelsPerMm != null)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.passGreenLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.passGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Active Scale: ${_pixelsPerMm!.toStringAsFixed(1)} px/mm',
                  style: GoogleFonts.inter(
                    color: AppTheme.passGreenText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
