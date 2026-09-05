import 'ocr_data.dart';
import 'dart:ui';
import 'dart:math';

class FactExtractor {
  static Map<String, dynamic> extractFacts(String flatText, List<OcrBlock> blocks, {double? pixelsPerMm}) {
    String lowerText = flatText.toLowerCase();
    
    Map<String, dynamic> facts = {
      // Rule 6(1)(a): Manufacturer Address
      'manufacturer_address': _containsAny(lowerText, ['mfg', 'manufactured by', 'packed by', 'pvt', 'ltd', 'estate', 'plot', 'phase', 'sector']),
      
      // Rule 6(1)(c): Net Quantity
      'net_quantity': _extractNetQuantity(lowerText, blocks) != null,
      'net_quantity_value': _extractNetQuantity(lowerText, blocks),
      
      // Rule 6(1)(e): MRP
      'mrp': _extractMRP(blocks) != null,
      'mrp_value': _extractMRP(blocks),
      
      // Rule 6(1)(d): Manufacture Date
      'manufacture_date': _extractDate(blocks, ['mfg', 'pkd', 'packed', 'mfd']) != null,
      'manufacture_date_value': _extractDate(blocks, ['mfg', 'pkd', 'packed', 'mfd']),
      
      // Rule 6(1)(da): Best Before / Use By
      'best_before_or_use_by': _extractDate(blocks, ['exp', 'expiry', 'best before', 'use by', 'use before']) != null,
      'best_before_or_use_by_value': _extractDate(blocks, ['exp', 'expiry', 'best before', 'use by', 'use before']),
      
      // Rule 6(2): Consumer Care
      'consumer_care_contact': _containsAny(lowerText, ['care', 'feedback', 'complaint', '@', 'toll free', 'call']),
      
      // Veg/Non-veg mark (usually needs computer vision, fallback to text)
      'veg_nonveg_mark': _containsAny(lowerText, ['green dot', 'brown dot', 'veg mark']),
      
      // Generic Commodity Name
      'commodity_name': flatText.length > 10,
    };

    // Rule 7 Font Height & Area Calculation
    // For MVP, we assume PDP area is roughly 100cm2 (between 50 and 2500) if not explicitly measured
    // But if we have pixelsPerMm from calibration, we can calculate font height
    if (pixelsPerMm != null && pixelsPerMm > 0) {
      facts['pdp_area_cm2'] = 100.0; // Defaulting to medium bucket for now, or could ask user
      
      // Calculate font height of Net Quantity block (or average of all key blocks)
      // We will just find the Net Quantity block and get its height
      double totalHeight = 0;
      int count = 0;
      for (var b in blocks) {
        if (_containsAny(b.text.toLowerCase(), ['net', 'qty', 'weight', 'g', 'ml', 'mrp', 'rs', 'exp', 'mfd'])) {
           totalHeight += b.boundingBox.height;
           count++;
        }
      }
      
      if (count > 0) {
         double avgPixelHeight = totalHeight / count;
         facts['font_height_mm'] = avgPixelHeight / pixelsPerMm;
      } else {
         facts['font_height_mm'] = 0.0; // couldn't find relevant blocks
      }
    }

    return facts;
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (var k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  /// Normalizes common OCR mistakes only in number contexts
  static String normalizeOcrDigits(String text) {
    // Replace S->5, O->0, l->1, I->1 but only if it looks like a number-like string
    // To do this simply, we replace them everywhere in the extracted substring 
    // because this function is only called on regex matches that are EXPECTED to be numbers/dates.
    return text
        .replaceAll('S', '5')
        .replaceAll('s', '5')
        .replaceAll('O', '0')
        .replaceAll('o', '0')
        .replaceAll('l', '1')
        .replaceAll('I', '1');
  }

  static String? _extractMRP(List<OcrBlock> blocks) {
    List<String> keywords = ['mrp', 'rs', '₹', 'inr', 'inclusive of all taxes', 'incl. of all taxes'];
    
    for (var block in blocks) {
      String bTextLower = block.text.toLowerCase();
      if (_containsAny(bTextLower, keywords)) {
        
        // Find price pattern: optional rs/mrp/₹, followed by spaces, followed by digits/letters resembling digits
        final regExp = RegExp(r'(?:rs\.?|₹|inr|mrp)\s*([0-9OoSsIl]{1,5}(?:\.[0-9OoSsIl]{1,2})?)');
        final match = regExp.firstMatch(bTextLower);
        if (match != null) {
          String normalized = normalizeOcrDigits(match.group(1)!);
          if (RegExp(r'\d+').hasMatch(normalized)) return normalized;
        }
        
        // If not in the same block, find the closest block to the right or bottom
        OcrBlock? closest = _findClosestBlock(block, blocks);
        if (closest != null) {
          String cText = closest.text.toLowerCase();
          final match2 = regExp.firstMatch(cText);
          if (match2 != null) {
            String normalized = normalizeOcrDigits(match2.group(1)!);
            if (RegExp(r'\d+').hasMatch(normalized)) return normalized;
          } else {
            // if it's just a number block (e.g. "20" or "O.SO")
            // It should be predominantly number-like characters.
            if (RegExp(r'^[\s0-9OoSsIl\.\,]+$').hasMatch(cText)) {
               String normalized = normalizeOcrDigits(cText.trim());
               if (RegExp(r'\d+').hasMatch(normalized)) return normalized;
            }
          }
        }
      }
    }
    return null;
  }

  static String? _extractNetQuantity(String text, List<OcrBlock> blocks) {
    // Looks for 500g, 1kg, 200ml, 1.5L, 50 N
    final regExp = RegExp(r'([0-9OoSsIl]+\.?[0-9OoSsIl]*)\s*(g|kg|ml|l|ltr|oz|lb|n|units|pcs)\b');
    final match = regExp.firstMatch(text);
    if (match != null) {
      String rawNum = match.group(1)!;
      String unit = match.group(2)!;
      String normalizedNum = normalizeOcrDigits(rawNum);
      if (RegExp(r'\d+').hasMatch(normalizedNum)) {
         return "$normalizedNum $unit";
      }
    }
    return null;
  }

  static String? _extractDate(List<OcrBlock> blocks, List<String> prefixes) {
    for (var block in blocks) {
      String bTextLower = block.text.toLowerCase();
      if (_containsAny(bTextLower, prefixes)) {
        // Loose date regex: 01/24, 01/2024, JAN 24, 12-25
        final dateRegExp = RegExp(r'([0-9OoSsIl]{2}[/\-\.][0-9OoSsIl]{2,4}|(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[\s\-\.]*[0-9OoSsIl]{2,4})');
        
        // Check in same block
        final match = dateRegExp.firstMatch(bTextLower);
        if (match != null) {
          return normalizeOcrDigits(match.group(0)!);
        }

        // Check nearest block
        OcrBlock? closest = _findClosestBlock(block, blocks);
        if (closest != null) {
          final closestMatch = dateRegExp.firstMatch(closest.text.toLowerCase());
          if (closestMatch != null) {
             return normalizeOcrDigits(closestMatch.group(0)!);
          }
        }
      }
    }
    return null;
  }

  static OcrBlock? _findClosestBlock(OcrBlock target, List<OcrBlock> allBlocks) {
    OcrBlock? closest;
    double minDistance = double.infinity;
    
    for (var b in allBlocks) {
      if (b == target) continue;
      
      // Calculate distance between centers
      double dx = b.boundingBox.center.dx - target.boundingBox.center.dx;
      double dy = b.boundingBox.center.dy - target.boundingBox.center.dy;
      
      // Only consider blocks that are roughly on the same line (to the right) or immediately below
      // Lay's case: "Incl. of all taxes" is one block, "Rs 20" is another block right next to it.
      if (dx > -50 && dy > -20 && dy < 150) {
        double dist = sqrt(dx*dx + dy*dy);
        if (dist < minDistance) {
          minDistance = dist;
          closest = b;
        }
      }
    }
    
    return closest;
  }
}
