const { Engine } = require('json-rules-engine');
const path = require('path');
const { buildEngineRules } = require('./json_adapter');

async function runRules(category, facts) {
    const engine = new Engine();
    
    // Load dynamic JSON rules
    const basePath = path.join(__dirname, 'rules', 'base.json');
    try {
        const rules = buildEngineRules(basePath);
        rules.forEach(rule => engine.addRule(rule));
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
