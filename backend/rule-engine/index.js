const { Engine } = require('json-rules-engine');
const path = require('path');
const fs = require('fs');

async function runRules(category, facts) {
    const engine = new Engine();
    
    // Load dynamic JSON rules
    // For production, we load from rules/base.json, but it is now the universal format
    const basePath = path.join(__dirname, 'rules', 'base.json');
    try {
        const rawData = fs.readFileSync(basePath, 'utf8');
        const data = JSON.parse(rawData);
        data.rules.forEach(rule => engine.addRule(rule));
    } catch (e) {
        throw new Error(`Failed to load or parse base.json rules: ${e.message}`);
    }

    // Mix in the category so conditional rules can check it
    const enhancedFacts = { ...facts, category };

    const { events } = await engine.run(enhancedFacts);
    
    return {
        compliant: events.length === 0, // Compliant if NO violations triggered
        violations: events.map(e => e.params)
    };
}

module.exports = { runRules };
