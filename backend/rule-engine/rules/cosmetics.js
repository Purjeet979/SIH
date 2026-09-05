const base = require('./base');

module.exports = {
  conditions: {
    all: [
      ...base.conditions.all,
      { fact: "hasVegNonVegDot", operator: "equal", value: true } // category-specific
    ]
  },
  event: { type: "compliant", params: { category: "cosmetics" } }
};
