import 'dart:convert';
import 'package:flutter/services.dart';

class Violation {
  final String ruleId;
  final String ruleNumber;
  final String title;
  final String severity;
  final String description;

  Violation({
    required this.ruleId,
    required this.ruleNumber,
    required this.title,
    required this.severity,
    required this.description,
  });
}

class RuleEngine {
  List<dynamic> _rules = [];

  Future<void> loadRules() async {
    try {
      final jsonString = await rootBundle.loadString('assets/base.json');
      final data = jsonDecode(jsonString);
      _rules = data['rules'] as List<dynamic>;
    } catch (e) {
      print("Error loading rules: $e");
    }
  }

  List<Violation> evaluate(Map<String, dynamic> facts) {
    List<Violation> violations = [];
    String category = facts['category'] ?? 'other';

    for (var r in _rules) {
      String field = r['field'];
      bool isRequired = r['required'] == true;
      String? condition = r['condition'];
      
      bool factValue = facts[field] == true;

      // 1. Unconditionally required fields
      if (isRequired) {
        if (!factValue) {
          violations.add(_createViolation(r));
        }
      } 
      // 2. Conditionally required fields
      else if (condition != null) {
        if (condition == 'applies_to_cosmetics_toiletries_categories' && category == 'cosmetics_toiletries') {
          if (!factValue) {
            violations.add(_createViolation(r));
          }
        }
        else if (condition == 'applies_if_perishable' && category == 'packaged_food') {
          if (!factValue) {
            violations.add(_createViolation(r));
          }
        }
        // Add more specific conditions based on base.json logic as needed
      }
    }
    
    return violations;
  }

  Violation _createViolation(Map<String, dynamic> ruleData) {
    return Violation(
      ruleId: ruleData['rule_id'] ?? '',
      ruleNumber: ruleData['rule_number'] ?? '',
      title: ruleData['title'] ?? '',
      severity: ruleData['severity'] ?? 'minor',
      description: ruleData['description'] ?? '',
    );
  }
}
