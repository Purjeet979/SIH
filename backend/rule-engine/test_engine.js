const { Engine } = require('json-rules-engine');
const fs = require('fs');
const path = require('path');

async function runTests() {
    console.log("Running Cross-platform Rule Engine Sync Tests (Node.js)");

    const engine = new Engine();
    
    // Load generic rules from fixtures
    const rulesPath = path.join(__dirname, '..', '..', 'test_fixtures', 'rules.json');
    const rulesData = JSON.parse(fs.readFileSync(rulesPath, 'utf8'));
    rulesData.rules.forEach(rule => engine.addRule(rule));

    // Load input facts
    const factsPath = path.join(__dirname, '..', '..', 'test_fixtures', 'input_facts.json');
    const cases = JSON.parse(fs.readFileSync(factsPath, 'utf8')).test_cases;

    let failed = 0;

    for (const tc of cases) {
        const { id, facts, expected_violations } = tc;
        
        // Wait, json-rules-engine treats missing values as undefined. 
        // Our Dart engine assumes missing bools are true.
        // But the input_facts JSON explicitly provides the booleans! 
        // So we don't need to worry about undefined for this test fixture.

        const { events } = await engine.run(facts);
        const actualRuleIds = events.map(e => e.params.rule_id);

        // Sort and compare arrays
        const expectedStr = [...expected_violations].sort().join(',');
        const actualStr = [...actualRuleIds].sort().join(',');

        if (expectedStr !== actualStr) {
            console.error(`[FAIL] Case ${id} failed. Expected: [${expectedStr}], Actual: [${actualStr}]`);
            failed++;
        } else {
            console.log(`[PASS] Case ${id}`);
        }
    }

    if (failed > 0) {
        process.exit(1);
    } else {
        console.log("All tests passed!");
        process.exit(0);
    }
}

runTests();
