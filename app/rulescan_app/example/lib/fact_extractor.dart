class FactExtractor {
  static Map<String, dynamic> extractFacts(String text) {
    String lowerText = text.toLowerCase();
    
    return {
      // Rule 6(1)(a): Manufacturer Address
      // Simple heuristic: looks for 'mfg', 'manufactured', 'ltd', 'pvt', 'address', 'estate', 'plot'
      'manufacturer_address': _containsAny(lowerText, ['mfg', 'manufactured by', 'packed by', 'pvt', 'ltd', 'estate', 'plot', 'phase', 'sector']),
      
      // Rule 6(1)(c): Net Quantity
      'net_quantity': _extractNetQuantity(lowerText) != null,
      'net_quantity_value': _extractNetQuantity(lowerText),
      
      // Rule 6(1)(e): MRP
      'mrp': _extractMRP(lowerText) != null,
      'mrp_value': _extractMRP(lowerText),
      
      // Rule 6(1)(d): Manufacture Date
      'manufacture_date': _extractDate(lowerText, ['mfg', 'pkd', 'packed']) != null,
      'manufacture_date_value': _extractDate(lowerText, ['mfg', 'pkd', 'packed']),
      
      // Rule 6(1)(da): Best Before / Use By
      'best_before_or_use_by': _extractDate(lowerText, ['exp', 'expiry', 'best before', 'use by']) != null,
      'best_before_or_use_by_value': _extractDate(lowerText, ['exp', 'expiry', 'best before', 'use by']),
      
      // Rule 6(2): Consumer Care
      'consumer_care_contact': _containsAny(lowerText, ['care', 'feedback', 'complaint', '@', 'toll free', 'call']),
      
      // Veg/Non-veg mark (usually needs computer vision, fallback to text)
      'veg_nonveg_mark': _containsAny(lowerText, ['green dot', 'brown dot', 'veg mark']),
      
      // Generic Commodity Name (heuristic: large text chunk, for now we just assume true if text is long enough)
      'commodity_name': text.length > 10,
    };
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (var k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  static String? _extractMRP(String text) {
    // Looks for MRP Rs. 150 or MRP 150 or MRP ₹150 or ₹150 or Rs 150
    // Simplified regex for flutter:
    final regExp = RegExp(r'(?:mrp|rs\.?|₹|inr)[\s:\-\.]*([0-9]+\.?[0-9]*)');
    final match = regExp.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  static String? _extractNetQuantity(String text) {
    // Looks for 500g, 1kg, 200ml, 1.5L, 50 N
    final regExp = RegExp(r'([0-9]+\.?[0-9]*)\s*(g|kg|ml|l|ltr|oz|lb|n|units|pcs)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      return match.group(0); // Return the whole string e.g. "500 g"
    }
    return null;
  }

  static String? _extractDate(String text, List<String> prefixes) {
    // Matches MM/YY, MM/YYYY, DD/MM/YY, DD/MM/YYYY
    for (var prefix in prefixes) {
      if (text.contains(prefix)) {
        // Find a date near this prefix
        final dateRegExp = RegExp(r'([0-9]{2}[/\-\.][0-9]{2,4}|[a-z]{3}[\s\-\.]*[0-9]{2,4})');
        // Search in a window of 30 characters after the prefix
        int startIndex = text.indexOf(prefix);
        int endIndex = (startIndex + 30 < text.length) ? startIndex + 30 : text.length;
        String window = text.substring(startIndex, endIndex);
        
        final match = dateRegExp.firstMatch(window);
        if (match != null) {
          return match.group(0);
        }
      }
    }
    return null;
  }
}
