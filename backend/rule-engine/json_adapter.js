const fs = require('fs');

function buildEngineRules(jsonPath) {
    const rawData = fs.readFileSync(jsonPath, 'utf8');
    const data = JSON.parse(rawData);
    const engineRules = [];

    data.rules.forEach(r => {
        // Event triggers when a condition is met (which means a violation occurred)
        const event = {
            type: 'violation',
            params: {
                rule_id: r.rule_id,
                rule_number: r.rule_number,
                title: r.title,
                severity: r.severity
            }
        };

        // 1. Unconditionally required fields (e.g., MRP, Net Quantity)
        // If the fact evaluates to 'false' (missing/invalid), we trigger a violation
        if (r.required) {
            engineRules.push({
                conditions: {
                    all: [{
                        fact: r.field,
                        operator: 'equal',
                        value: false
                    }]
                },
                event
            });
        } 
        // 2. Conditionally required fields
        else if (r.condition) {
            // Example: Cosmetics & Toiletries (veg/non-veg mark)
            if (r.condition === 'applies_to_cosmetics_toiletries_categories') {
                engineRules.push({
                    conditions: {
                        all: [
                            { fact: 'category', operator: 'equal', value: 'cosmetics_toiletries' },
                            { fact: r.field, operator: 'equal', value: false }
                        ]
                    },
                    event
                });
            }
            // Example: Perishables
            else if (r.condition === 'applies_if_perishable') {
                engineRules.push({
                    conditions: {
                        all: [
                            { fact: 'category', operator: 'equal', value: 'packaged_food' },
                            { fact: r.field, operator: 'equal', value: false }
                        ]
                    },
                    event
                });
            }
            // Extend with more condition logic based on the LMPC categories...
        }
    });

    return engineRules;
}

module.exports = { buildEngineRules };
