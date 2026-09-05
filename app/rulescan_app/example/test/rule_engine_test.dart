import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ocr_kit_example/rule_engine.dart';

void main() {
  group('Cross-platform Rule Engine Sync Tests', () {
    test('Dart engine matches expected fixture violations', () {
      final engine = RuleEngine();
      
      // Load rules from fixture
      final rulesFile = File('../../../test_fixtures/rules.json');
      engine.setRulesFromJson(rulesFile.readAsStringSync());

      // Load input facts
      final factsFile = File('../../../test_fixtures/input_facts.json');
      final factsJson = jsonDecode(factsFile.readAsStringSync());
      final List<dynamic> cases = factsJson['test_cases'];

      for (var tc in cases) {
        String caseId = tc['id'];
        Map<String, dynamic> facts = tc['facts'];
        List<dynamic> expectedRuleIds = tc['expected_violations'];

        List<Violation> result = engine.evaluate(facts);
        List<String> actualRuleIds = result.map((v) => v.ruleId).toList();

        expect(
          actualRuleIds.toSet(), 
          expectedRuleIds.toSet(), 
          reason: 'Case $caseId failed. Expected: $expectedRuleIds, Actual: $actualRuleIds'
        );
      }
    });
  });
}
