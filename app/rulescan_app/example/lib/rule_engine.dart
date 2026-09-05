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

  // Exposed for unit testing with shared fixtures
  void setRulesFromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    _rules = data['rules'] as List<dynamic>;
  }

  Future<void> loadRules(String category) async {
    _rules = [];
    try {
      final commonString = await rootBundle.loadString('assets/common.json');
      _rules.addAll(jsonDecode(commonString)['rules'] as List<dynamic>);
      
      try {
         final categoryString = await rootBundle.loadString('assets/$category.json');
         _rules.addAll(jsonDecode(categoryString)['rules'] as List<dynamic>);
      } catch (e) {
         // It's okay if a category-specific JSON doesn't exist, just use common
         print("No specific rules found for $category");
      }
    } catch (e) {
      print("Error loading rules: $e");
    }
  }

  List<Violation> evaluate(Map<String, dynamic> facts) {
    List<Violation> violations = [];
    
    for (var rule in _rules) {
      if (!rule.containsKey('conditions') || !rule['conditions'].containsKey('all')) continue;
      
      List<dynamic> conditions = rule['conditions']['all'];
      bool allConditionsMet = true;

      for (var cond in conditions) {
        String factName = cond['fact'];
        String op = cond['operator'];
        dynamic expectedValue = cond['value'];
        dynamic actualValue = facts[factName];

        // If fact is totally missing from input, treat booleans as true by default, else null
        if (actualValue == null && expectedValue is bool) {
           actualValue = true; // Rule engine assumption: fields exist unless explicitly flagged false
           // Wait, for rule engine, if we pass missing MRP, actualValue is null.
           // In JS, missing is undefined.
        }

        bool condMet = false;
        bool isBorderline = false;
        switch (op) {
          case 'equal':
            condMet = (actualValue == expectedValue);
            break;
          case 'notEqual':
            condMet = (actualValue != expectedValue);
            break;
          case 'lessThan':
            if (actualValue is num && expectedValue is num) {
              condMet = actualValue < expectedValue;
              if (!condMet && (actualValue - expectedValue) <= 0.2) {
                 isBorderline = true;
              }
            }
            break;
          case 'greaterThanInclusive':
            if (actualValue is num && expectedValue is num) {
              condMet = actualValue >= expectedValue;
              if (!condMet && (expectedValue - actualValue) <= 0.2) {
                 isBorderline = true;
              }
            }
            break;
        }

        if (!condMet) {
          allConditionsMet = false;
          // If we failed a font height check marginally, we don't break, we let it fail 
          // but we track that it was borderline.
          if (isBorderline && factName == 'font_height_mm') {
            rule['_isBorderline'] = true;
          }
          break; // Stop evaluating this rule's conditions
        }
      }

      if (allConditionsMet && rule.containsKey('event')) {
        violations.add(_createViolation(rule['event']['params']));
      } else if (!allConditionsMet && rule['_isBorderline'] == true) {
        // Advisory flag
        Map<String, dynamic> params = Map.from(rule['event']['params']);
        params['severity'] = 'warning';
        params['title'] = '[ADVISORY] ${params['title']}';
        params['description'] = '${params['description']} (Borderline measurement. Verify manually)';
        violations.add(_createViolation(params));
        rule['_isBorderline'] = false; // reset
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
