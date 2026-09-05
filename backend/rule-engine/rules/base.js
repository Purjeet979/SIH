module.exports = {
  conditions: {
    all: [
      { fact: "hasMRP", operator: "equal", value: true },
      { fact: "hasNetQuantity", operator: "equal", value: true }
    ]
  }
};
