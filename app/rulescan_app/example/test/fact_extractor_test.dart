import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ocr_kit_example/fact_extractor.dart';
import 'package:flutter_ocr_kit_example/ocr_data.dart';
import 'dart:ui';

void main() {
  group('FactExtractor QA Tests', () {
    
    // Helper to create simple blocks
    OcrBlock createBlock(String text, double x, double y) {
      return OcrBlock(
        text: text,
        boundingBox: Rect.fromLTWH(x, y, 100, 20),
        lines: [],
      );
    }

    test('Pass: Parle-G Net Quantity (Handling OCR S->5 confusion)', () {
      // OCR often reads 50g as S0g
      List<OcrBlock> blocks = [
        createBlock('PARLE-G', 10, 10),
        createBlock('Net Weight: S0g', 10, 40),
      ];
      final facts = FactExtractor.extractFacts('PARLE-G Net Weight: S0g', blocks);
      
      expect(facts['net_quantity'], true);
      expect(facts['net_quantity_value'], '50 g');
    });

    test('Pass: Lay\'s Chips MRP Multi-line (Proximity Test)', () {
      // Lay's often prints "Incl. of all taxes" and "Rs. 20" separately
      List<OcrBlock> blocks = [
        createBlock('Lay\'s Classic', 10, 10),
        createBlock('Incl. of all taxes', 10, 50),
        createBlock('Rs. 20', 120, 50), // Same Y, to the right
      ];
      final facts = FactExtractor.extractFacts('Lay\'s Classic Incl. of all taxes Rs. 20', blocks);
      
      expect(facts['mrp'], true);
      expect(facts['mrp_value'], '20');
    });

    test('Pass: Nivea Cream Expiry Date (Date normalization)', () {
      // OCR reads 'EXP 10/25' as 'EXP l0/2S'
      List<OcrBlock> blocks = [
        createBlock('Nivea Soft', 10, 10),
        createBlock('EXP l0/2S', 10, 30),
      ];
      final facts = FactExtractor.extractFacts('Nivea Soft EXP l0/2S', blocks);
      
      expect(facts['best_before_or_use_by'], true);
      expect(facts['best_before_or_use_by_value'], '10/25');
    });

    test('Pass: Chheda\'s Diet Poha (Far proximity date)', () {
      // MFD prefix is at (10, 100) but date is at (150, 100)
      List<OcrBlock> blocks = [
        createBlock('Chheda Diet Poha', 10, 10),
        createBlock('MFD:', 10, 100),
        createBlock('04/2024', 150, 100),
      ];
      final facts = FactExtractor.extractFacts('Chheda Diet Poha MFD: 04/2024', blocks);
      
      expect(facts['manufacture_date'], true);
      expect(facts['manufacture_date_value'], '04/2024');
    });

    test('Pass: Normalizing O -> 0 in MRP', () {
      List<OcrBlock> blocks = [
        createBlock('MRP O.SO', 10, 10), // OCR read 0.50 as O.SO
      ];
      final facts = FactExtractor.extractFacts('MRP O.SO', blocks);
      expect(facts['mrp'], true);
      expect(facts['mrp_value'], '0.50');
    });

    // --- NON-COMPLIANT CASES ---

    test('Flag: Missing MRP genuinely (No numbers nearby)', () {
      List<OcrBlock> blocks = [
        createBlock('Generic Snack', 10, 10),
        createBlock('Incl. of all taxes', 10, 50),
        createBlock('Buy 1 Get 1 Free', 120, 50), 
      ];
      final facts = FactExtractor.extractFacts('Generic Snack Incl. of all taxes Buy 1 Get 1 Free', blocks);
      
      expect(facts['mrp'], false);
    });

    test('Flag: Missing Net Quantity genuinely (No units)', () {
      List<OcrBlock> blocks = [
        createBlock('Fresh Apples', 10, 10),
        createBlock('500', 10, 40), // 500 without g/kg
      ];
      final facts = FactExtractor.extractFacts('Fresh Apples 500', blocks);
      
      expect(facts['net_quantity'], false);
    });
  });
}
