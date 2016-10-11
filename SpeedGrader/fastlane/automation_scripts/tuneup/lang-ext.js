/**
 * Extend +destination+ with +source+
 */
function extend(destination, source) {
  for (var property in source) {
    destination[property] = source[property];
  }
  return destination;
}

/**
 * Dump the properties out a String returned by the function.
 */
function dumpProperties(_this) {
  var dumpStr = "";
  for (var propName in _this) {
    if (_this.hasOwnProperty(propName)) {
      if (dumpStr !== "") {
        dumpStr += ", ";
      }
      dumpStr += (propName + "=" + _this[propName]);
    }
  }

  return dumpStr;
};

function getMethods(_this) {
  var methods = [];
  for (var m in _this) {
    //if (typeof _this[m] == "function" && _this.hasOwnProperty(m)) {
    if (typeof _this[m] == "function") {
      methods.push(m);
    }
  }
  return methods;
}

extend(Array.prototype, {
  /**
   * Applies the given function to each element in the array until a
   * match is made. Otherwise returns null.
   * */
  contains: function(f) {
    for (i = 0; i < this.length; i++) {
      if (f(this[i])) {
        return this[i];
      }
    }
    return null;
  },

  unique:  function() {
    function onlyUnique(value, index, self) {
      return self.indexOf(value) === index;
    }

    return this.filter(onlyUnique);
  }
});

String.prototype.trim = function() {
  return this.replace(/^\s+|\s+$/g,"");
};

String.prototype.ltrim = function() {
  return this.replace(/^\s+/,"");
};

String.prototype.rtrim = function() {
  return this.replace(/\s+$/,"");
};

String.prototype.lcfirst = function() {
  return this.charAt(0).toLowerCase() + this.substr(1);
};
