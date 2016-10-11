Screen = {
  screens: {},
  
  add: function(name, definition) {
    this.screens[name] = definition;
  },
  
  named: function(name) {
    return this.screens[name];
  }
};
