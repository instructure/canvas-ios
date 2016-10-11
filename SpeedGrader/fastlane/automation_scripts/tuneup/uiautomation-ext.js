#import "assertions.js";
#import "lang-ext.js";

//We cannot instantiate a UIAElementNil and still get our extensions, so we hold onto one.
UIAElementNilSingleton =  UIATarget.localTarget().frontMostApp().mainWindow().staticTexts().firstWithName("notFoundx123hfhfhfhfhfhed");

extend(UIATableView.prototype, {
  /**
   * A shortcut for:
   *  this.cells().firstWithName(name)
   */
  cellNamed: function (name) {
    return this.cells().firstWithName(name);
  },

  /**
   * Asserts that this table has a cell with the name (accessibility label)
   * matching the given +name+ argument.
   */
  assertCellNamed: function (name) {
    assertNotNull(this.cellNamed(name), "No table cell found named '" + name + "'");
  }
});

var isNotNil = function () {
  var ret = undefined !== this && null != this && this.toString() != "[object UIAElementNil]";
  return ret;
};

extend(UIAElementArray.prototype, {
  /**
   * Same as withName, but takes a regular expression
   */
  withNameRegex: function(pattern) {
    var ret = [];
    for (var i = 0; i < this.length; ++i) {
      var elem = this[i];
      if (elem.isNotNil && elem.isNotNil() && elem.name() && elem.name().match(pattern) !== null) {
        ret.push(elem);
      }
    }
    return ret;
  },

  /**
   * Same as firstWithName, but takes a regular expression
   */
  firstWithNameRegex: function(pattern) {
    for (var i = 0; i < this.length; ++i) {
      var elem = this[i];
      if (elem.isNotNil && elem.isNotNil() && elem.name() && elem.name().match(pattern) !== null) return elem;
    }
    return new UIAElementNil();
  }
});

extend(UIAElement.prototype, {

  /**
   * Creates a screenshot of the UIElement and saves it to the log directory with the given name
   */
  captureWithName: function(capture_name) {
    var target = UIATarget.localTarget();
    target.captureRectWithName(this.rect(), capture_name);
  },
  /**
   * Equality operator
   *
   * Properly detects equality of 2 UIAElement objects
   * - Can return false positives if 2 elements (and ancestors) have the same name, type, and rect()
   */
  equals: function(elem2, maxRecursion) {
    maxRecursion = maxRecursion === undefined ? -1 : maxRecursion;
    if (this == elem2) return true; // shortcut when x == x
    if (null === elem2) return false; // shortcut when one is nil
    if (!this.isNotNil() || !elem2.isNotNil()) return !this.isNotNil() && !elem2.isNotNil(); // both nil or neither
    if (this.toString() != elem2.toString()) return false; // element type
    if (this.name() != elem2.name()) return false;
    if (JSON.stringify(this.rect()) != JSON.stringify(elem2.rect())) return false; // possible false positives!
    if (0 == maxRecursion) return true; // stop recursing?
    if (-100 == maxRecursion) UIALogger.logWarning("Passed 100 recursions in UIAElement.equals");
    return this.parent() === null || this.parent().equals(elem2.parent(), maxRecursion - 1); // check parent elem
  },

  /**
   * General-purpose reduce function
   *
   * Applies the callback function to each node in the element tree starting from the current element.
   *
   * Callback function takes (previousValue, currentValue <UIAElement>, accessor_prefix, toplevel <UIAElement>)
   *     where previousValue is: initialValue (first time), otherwise the previous return from the callback
   *           currentValue is the UIAElement at the current location in the tree
   *           accessor_prefix is the code to access this element from the toplevel element
   *           toplevel is the top-level element on which this reduce function was called
   *
   * visibleOnly prunes the search tree to visible elements only
   */
  _reduce: function(callback, initialValue, visibleOnly) {
    var reduce_helper = function (elem, acc, prefix) {
      var scalars = ["navigationBar", "popover", "tabBar", "toolbar"];
      var vectors = ["activityIndicators", "buttons", "cells", "collectionViews", "images", "links", "navigationBars",
                     "pageIndicators", "pickers", "progressIndicators", "scrollViews", "searchBars",
                     "secureTextFields", "segmentedControls", "sliders", "staticTexts", "switches", "tabBars",
                     "tableViews", "textFields", "textViews", "toolbars", "webViews"];

      // function to visit an element, and add it to an array of what was discovered
      var accessed = [];
      var visit = function(someElem, accessor, onlyConsiderNew) {
        // filter invalid
        if (undefined === someElem) return;
        if (!someElem.isNotNil()) return;

        // filter already visited (in cases where we care)
        if (onlyConsiderNew) {
          for (var i = 0; i < accessed.length; ++i) {
            if (accessed[i].equals(someElem, 0)) return;
          }
        }
        accessed.push(someElem);

        // filter based on visibility
        if (visibleOnly && !someElem.isVisible()) return;
        acc = reduce_helper(someElem, callback(acc, someElem, accessor, this), accessor);
      };

      // try to access an element by name instead of number
      var getNamedIndex = function(someArray, numericIndex) {
        var e = someArray[numericIndex];
        var name = e.name();
        if (name !== null && e.equals(someArray.firstWithName(name), 0)) return '"' + name + '"';
        return numericIndex;
      }

      // visit scalars
      for (var i = 0; i < scalars.length; ++i) {
        visit(elem[scalars[i]](), prefix + "." + scalars[i] + "()", false);
      }

      // visit the elements of the vectors
      for (var i = 0; i < vectors.length; ++i) {
        if (undefined === elem[vectors[i]]) continue;
        var elemArray = elem[vectors[i]]();
        if (undefined === elemArray) continue;
        for (var j = 0; j < elemArray.length; ++j) {
          var newElem = elemArray[j];
          visit(newElem, prefix + "." + vectors[i] + "()[" + getNamedIndex(elemArray, j) + "]", false);
        }
      }

      // visit any un-visited items
      var elemArray = elem.elements()
      for (var i = 0; i < elemArray.length; ++i) {
        visit(elemArray[i], prefix + ".elements()[" + getNamedIndex(elemArray, i) + "]", true);
      }
      return acc;
    };

    UIATarget.localTarget().pushTimeout(0);
    try {
      return reduce_helper(this, initialValue, "");
    } catch(e) {
      throw e;
    } finally {
      UIATarget.localTarget().popTimeout();
    }

  },

  /**
   * Reduce function
   *
   * Applies the callback function to each node in the element tree starting from the current element.
   *
   * Callback function takes (previousValue, currentValue <UIAElement>, accessor_prefix, toplevel <UIAElement>)
   *     where previousValue is: initialValue (first time), otherwise the previous return from the callback
   *           currentValue is the UIAElement at the current location in the tree
   *           accessor_prefix is the code to access this element from the toplevel element
   *           toplevel is the top-level element on which this reduce function was called
   */
  reduce: function(callback, initialValue) {
    return this._reduce(callback, initialValue, false);
  },

  /**
   * Reduce function
   *
   * Applies the callback function to each visible node in the element tree starting from the current element.
   *
   * Callback function takes (previousValue, currentValue <UIAElement>, accessor_prefix, toplevel <UIAElement>)
   *     where previousValue is: initialValue (first time), otherwise the previous return from the callback
   *           currentValue is the UIAElement at the current location in the tree
   *           accessor_prefix is the code to access this element from the toplevel element
   *           toplevel is the top-level element on which this reduce function was called
   */
  reduceVisible: function(callback, initialValue) {
    return this._reduce(callback, initialValue, true);
  },

  /**
   * Find function
   *
   * Find elements by given criteria
   *
   * Return associative array {accessor: element} of results
   */
  find: function(criteria, varName) {
    if (criteria === undefined) {
      UIALogger.logWarning("No criteria passed to find function, so assuming {} and returning all elements");
      criteria = {};
    }
    varName = varName === undefined ? "<root element>" : varName;
    var visibleOnly = criteria.isVisible === true;

    var knownOptions = {UIAtype: 1, rect: 1, hasKeyboardFocus: 1, isEnabled: 1, isValid: 1,
                        label: 1, name: 1, nameRegex: 1, value: 1};

    // helpful check, mostly catching capitalization errors
    for (var k in criteria) {
      if (knownOptions[k] === undefined) {
        UIALogger.logWarning(this.toString() + ".find() received unknown criteria field '" + k + "' "
                             + "(known fields are " + Object.keys(knownOptions).join(", ") + ")");

      }
    }

    var c = criteria;
    var collect_fn = function(acc, elem, prefix, _) {
      if (c.UIAtype !== undefined && "[object " + c.UIAtype + "]" != elem.toString()) return acc;
      if (c.rect !== undefined && JSON.stringify(c.rect) != JSON.stringify(elem.rect())) return acc;
      if (c.hasKeyboardFocus !== undefined && c.hasKeyboardFocus != elem.hasKeyboardFocus()) return acc;
      if (c.isEnabled !== undefined && c.isEnabled != elem.isEnabled()) return acc;
      if (c.isValid !== undefined && c.isValid !== elem.isValid()) return acc;
      if (c.label !== undefined && c.label != elem.label()) return acc;
      if (c.name !== undefined && c.name != elem.name()) return acc;
      if (c.nameRegex !== undefined && (elem.name() === null || elem.name().match(c.nameRegex) === null)) return acc;
      if (c.value !== undefined && c.value != elem.value()) return acc;

      acc[varName + prefix] = elem;
      return acc;
    }

    return this._reduce(collect_fn, {}, visibleOnly);
  },

  /**
   * Dump tree in .js format for copy/paste use in code
   * varname is used as the first element in the canonical name
   */
  elementAccessorDump: function(varName, visibleOnly) {
    varName = varName === undefined ? "<root element>" : varName;
    var title = "elementAccessorDump";
    if (visibleOnly === true) {
      title += " (of visible elements)";
      if (!this.isVisible()) return title + ": <none, " + varName + " is not visible>";
    }

    var collect_fn = function (acc, _, prefix, __) {
      acc.push(varName + prefix)
      return acc;
    };

    return this._reduce(collect_fn, [title + " of " + varName + ":", varName], visibleOnly).join("\n");
  },

  /**
   * Dump tree in json format for copy/paste use in AssertWindow and friends
   */
  elementJSONDump: function (recursive, attributes, visibleOnly) {
    if (visibleOnly && !this.isVisible()) {
      return "";
    }

    if (!attributes) {
      attributes = ["name", "label", "value", "isVisible"];
    }
    else if (attributes == 'ALL') {
      attributes = ["name",
        "label",
        "value"
      ].concat(getMethods(this).filter(function (method) {
        return method.match(/^(is|has)/)
      }));
    }

    var jsonStr = "";
    attributes.forEach(function (attr) {
      try {
        var value = this[attr]();
        if (value != null) { //don't print null values
          var valueType = typeof (value);
          //quote strings and numbers.  true/false unquoted.
          if (valueType == "string" || valueType == "number") {
            value = "'" + value + "'";
          }
          jsonStr += attr + ': ' + value + ',\n';
        }
      }
      catch (e) {}
    }, this);

    if (recursive) {
      var children = this.elements().toArray();
      if (children.length > 0) {
        var curType = null;
        children.sort().forEach(function (child) {

          function elementTypeToUIAGetter(elementType, parent) {

            //almost all types follow a simple name to getter convention.
            //UIAImage => images.  UIAWindow => windows.
            var getter = elementType.substring(3).lcfirst() + 's';
            if (elementType == "UIACollectionCell" || elementType == "UIATableCell") {
              getter = "cells";
            }
            if (parent && !eval('parent.' + getter)) {
              //Note: we can't use introspection to list valid methods on the parents
              //because they are all "native" methods and aren't visible.
              //so the valid getter must be looked up in the documentation and mapped above
              UIALogger.logError("elementTypeToUIAGetter could not determine getter for " + elementType);
            }
            return elementType.substring(3).lcfirst() + 's';
          }

          var objType = Object.prototype.toString.call(child); //[object UIAWindow]
          objType = objType.substring(8, objType.length - 1); //UIAWindow
          // there's a bug that causes leaf elements to have child references
          // back up to UIAApplication, thus the check for that
          // this means we can't dump from the "target" level - only mainWindow and below
          // hopefully this bug goes away 2013-07-02
          if (objType == "UIAApplication" || objType == "UIAElementNil" || (visibleOnly && !child.isVisible())) {
            //skip this child
            return;
          }

          if (objType == "UIACollectionCell" && !this.isVisible()) {
            //elements() shows invisible cells that cells() does not
            return;
          }
          if (curType && curType != objType) {
            //close off open list
            jsonStr += "],\n";
          }
          if (!curType || curType != objType) {
            curType = objType;
            //open a new list
            jsonStr += elementTypeToUIAGetter(objType, this) + ": [\n";
          }

          var childJsonStr = child.elementJSONDump(true, attributes, visibleOnly);
          if (childJsonStr) {
            jsonStr += "{\n";
            jsonStr += childJsonStr.replace(/^/gm, "    ").replace(/    $/, '');
            jsonStr += "},\n";
          }
          else {
            //child has no attributes to report (all null)
            jsonStr += "    null,\n";
          }

        }, this);
        if (curType) {
          //close off open list
          jsonStr += "],\n";
        }
      }
    }

    return jsonStr;
  },

  logElementJSON: function (attributes) {
    //TODO dump the path to the object in the debug line
    //ex: target.frontMostApp().mainWindow().toolbars()[0].buttons()["Library"]
    UIALogger.logDebug("logElementJSON: " + (attributes ? "[" + attributes + "]" : '') + "\n" + this.elementJSONDump(false, attributes));
  },

  logVisibleElementJSON: function (attributes) {
    //TODO dump the path to the object in the debug line
    //ex: target.frontMostApp().mainWindow().toolbars()[0].buttons()["Library"]
    UIALogger.logDebug("logVisibleElementJSON: " + (attributes ? "[" + attributes + "]" : '') + "\n" + this.elementJSONDump(false, attributes, true));
  },

  logElementTreeJSON: function (attributes) {
    UIALogger.logDebug("logElementTreeJSON: " + (attributes ? "[" + attributes + "]" : '') + "\n" + this.elementJSONDump(true, attributes));
  },

  logVisibleElementTreeJSON: function (attributes) {
    UIALogger.logDebug("logVisibleElementTreeJSON: " + (attributes ? "[" + attributes + "]" : '') + "\n" + this.elementJSONDump(true, attributes, true));
  },


  /**
   * Poll till the item becomes visible, up to a specified timeout
   */
  waitUntilVisible: function (timeoutInSeconds) {
    this.waitUntil(function (element) {
      return element;
    }, function (element) {
      return element.isVisible();
    }, timeoutInSeconds, "to become visible");
  },

  /**
   * Wait until element becomes invisible
   */
  waitUntilInvisible: function (timeoutInSeconds) {
    this.waitUntil(function (element) {
      return element;
    }, function (element) {
      return !element.isVisible();
    }, timeoutInSeconds, "to become invisible");
  },

  /**
   * Wait until child element with name is added
   */
  waitUntilFoundByName: function (name, timeoutInSeconds) {
    this.waitUntil(function (element) {
      return element.elements().firstWithName(name);
    }, function (element) {
      return element.isValid();
    }, timeoutInSeconds, ["to become valid (with name '", name, "')"].join(""));
  },

  /**
   * Wait until child element with name is removed
   */
  waitUntilNotFoundByName: function (name, timeoutInSeconds) {
    this.waitUntil(function (element) {
      return element.elements().firstWithName(name);
    }, function (element) {
      return !element.isValid();
    }, timeoutInSeconds, ["to become invalid (with name '", name, "'')"].join(""));
  },


  /**
   * Wait until lookup_function(this) returns a valid lookup
   *  For convenience, return the element that was found
   *  Allow a label for more helpful error messages
   */
  waitUntilAccessorSuccess: function (lookup_function, timeoutInSeconds, label) {
    var isNotUseless = function (elem) {
      return elem !== null && elem.isNotNil();
    }

    // this function will be referenced in waitUntil -- it supplies
    //   the name of what we are waiting for
    var label_fn = function () {
      return label;
    }

    if (!isNotUseless(this)) {
      throw "waitUntilAccessorSuccess: won't work because the top element isn't valid";
    }

    this.waitUntil(function (element) {
        // annotate the found elements with the label function if they are nil
        try {
          var possibleMatch = lookup_function(element);
          if (!possibleMatch.isNotNil() && label !== undefined) possibleMatch.label = label_fn;
          return possibleMatch;
        }
        catch (e) {
          var fakeNil = new UIAElementNil();
          if (label !== undefined) fakeNil.label = label_fn;
          return fakeNil;
        }
      }, isNotUseless,
      timeoutInSeconds, "to become an acceptable return value from the given function");
    return lookup_function(this);
  },


  /**
   * Wait until one lookup_function(this) in an associative array of lookup functions
   *  returns a valid lookup.
   *
   *  Return an associative array of {key: <element found>, elem: <the element that was found>}
   */
  waitUntilAccessorSelect: function (lookup_functions, timeoutInSeconds) {
    var isNotUseless = function (elem) {
      return elem !== null && elem.isNotNil();
    }

    if (!isNotUseless(this)) {
      throw "waitUntilAccessorSelect: won't work because the top element isn't valid";
    }

    // composite find function
    var find_any = function (element) {
      for (var k in lookup_functions) {
        var lookup_function = lookup_functions[k];
        try {
          var el = lookup_function(element);
          if (isNotUseless(el)) return {key: k, elem: el};
        }
        catch (e) {
          // ignore
        }
      }
      return UIAElementNilSingleton; //do not create a new UIAElementNil as our prototype extensions are not on that object.
    };

    //cache find_any() results since we want to use the values later. We don't want to reinvokve find_any() because the UI might have changed since we last found something
    //and if it no longer finds anything then find_any() will return UIAElementNil(), which we would then return, breaking the api contract to return a {key: elem:} object.
    var successfulResult = null;

    this.waitUntil(function (element) {
        var result = find_any(element);
        if (undefined !== result && result !== UIAElementNilSingleton) {  //find_any() will return UIAElementNilSingleton if not found and we don't want to start processing that-especially not result["elem"]
	      successfulResult = result;
	      return result["elem"];
        } 
        // we cannot support annotating the found elements with the label function if they are nil, because we reuse UIAElementNilSingleton
		return UIAElementNilSingleton;
      }, isNotUseless,
      timeoutInSeconds, "to produce any acceptable return values");
    return successfulResult;
  },


  /**
   * Wait until the element has the given name
   */
  waitUntilHasName: function (name, timeoutInSeconds) {

    this.waitUntil(function (element) {
      return element;
    }, function (element) {
      return element.name() == name;
    }, timeoutInSeconds, "to have the name '" + name + "'");

  },


  /**
   * Wait until element fulfills condition
   */
  waitUntil: function (filterFunction, conditionFunction, timeoutInSeconds, description) {
    timeoutInSeconds = timeoutInSeconds == null ? 5 : timeoutInSeconds;
    var element = this;
    var delay = 0.25;
    UIATarget.localTarget().pushTimeout(0);
    try {
      retry(function () {
        var filteredElement = filterFunction(element);
        if (!conditionFunction(filteredElement)) {
          if (!(filteredElement !== null && filteredElement.isNotNil())) {
            var label = (filteredElement && filteredElement.label) ? filteredElement.label() : "Element";
            // make simple error message if the element doesn't exist
            throw ([label, "failed", description,
              "within", timeoutInSeconds, "seconds."
            ].join(" "));
          }
          else {
            // build a detailed error message with all available info on the current element
            var elementDescription = filteredElement.toString();
            if (filteredElement.name !== undefined) {
              var elemName = filteredElement.name();
              if (elemName !== null && elemName != "") {
                elementDescription += " with name '" + elemName + "'";
              }
            }
            throw (["Element", elementDescription,
              "failed", description,
              "within", timeoutInSeconds, "seconds."
            ].join(" "));
          }
        }
      }, Math.max(1, timeoutInSeconds / delay), delay);
    }
    catch (e) {
      throw e;
    }
    finally {
      UIATarget.localTarget().popTimeout();
    }

  },

  /**
   * A shortcut for waiting an element to become visible and tap.
   */
  vtap: function (timeout) {
    if (undefined === timeout) timeout = 10;
    this.waitUntilVisible(timeout);
    this.tap();
  },

  /**
   * A shortcut for scrolling to a visible item and and tap.
   */
  svtap: function (timeout) {
    if (undefined === timeout) timeout = 1;
    try {
      this.scrollToVisible();
    } catch (e) {
      // iOS 6 hack when no scrolling is needed
      if (e.toString() != "scrollToVisible cannot be used on the element because it does not have a scrollable ancestor.") {
        throw e;
      }
    }
    //this.waitUntilVisible(timeout);
    this.tap();
  },
  /**
   * A shortcut for touching an element and waiting for it to disappear.
   */
  tapAndWaitForInvalid: function () {
    this.tap();
    this.waitForInvalid();
  },

  /**
   * verify that a text field is editable by tapping in it and waiting for a keyboard to appear.
   */
  checkIsEditable: function () {
    try {
      var keyboardWasUp = target.frontMostApp().keyboard().isVisible();

      // warn user if this is an object that might be destructively or oddly affected by this check
      switch (this.toString()) {
      case "[object UIAButton]":
      case "[object UIALink]":
      case "[object UIAActionSheet]":
      case "[object UIAKey]":
      case "[object UIAKeyboard]":
        UIALogger.logWarning("checkIsEditable is going to tap() an object of type " + this.toString());
      default:
        this.tap();
      }

      // wait for keyboard to disappear if it was already active
      if (keyboardWasUp) UIATarget.localTarget().delay(0.35);
      target.frontMostApp().keyboard().waitUntilVisible(2);
      return true;
    } catch (e) {
      return false;
    }
  },

  isNotNil: isNotNil,
});

extend(UIAElementNil.prototype, {
  isNotNil: function () {
    return false;
  },
  isValid: function () {
    return false;
  },
  isVisible: function () {
    return false;
  }
});

extend(UIAApplication.prototype, {
  /**
   * A shortcut for getting the current view controller's title from the
   * navigation bar. If there is no navigation bar, this method returns null
   */
  navigationTitle: function () {
    navBar = this.mainWindow().navigationBar();
    if (navBar) {
      return navBar.name();
    }
    return null;
  },

  /**
   * A shortcut for checking that the interface orientation in either
   * portrait mode
   */
  isPortraitOrientation: function () {
    var orientation = this.interfaceOrientation();
    return orientation == UIA_DEVICE_ORIENTATION_PORTRAIT ||
      orientation == UIA_DEVICE_ORIENTATION_PORTRAIT_UPSIDEDOWN;
  },

  /**
   * A shortcut for checking that the interface orientation in one of the
   * landscape orientations.
   */
  isLandscapeOrientation: function () {
    var orientation = this.interfaceOrientation();
    return orientation == UIA_DEVICE_ORIENTATION_LANDSCAPELEFT ||
      orientation == UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT;
  }
});

extend(UIANavigationBar.prototype, {
  /**
   * Asserts that the left button's name matches the given +name+ argument
   */
  assertLeftButtonNamed: function (name) {
    assertEquals(name, this.leftButton().name());
  },

  /**
   * Asserts that the right button's name matches the given +name+ argument
   */
  assertRightButtonNamed: function (name) {
    assertEquals(name, this.rightButton().name());
  }
});

extend(UIATarget.prototype, {
  /**
   * A shortcut for checking that the interface orientation in either
   * portrait mode
   */
  isPortraitOrientation: function () {
    var orientation = this.deviceOrientation();
    return orientation == UIA_DEVICE_ORIENTATION_PORTRAIT ||
      orientation == UIA_DEVICE_ORIENTATION_PORTRAIT_UPSIDEDOWN;
  },

  /**
   * A shortcut for checking that the interface orientation in one of the
   * landscape orientations.
   */
  isLandscapeOrientation: function () {
    var orientation = this.deviceOrientation();
    return orientation == UIA_DEVICE_ORIENTATION_LANDSCAPELEFT ||
      orientation == UIA_DEVICE_ORIENTATION_LANDSCAPERIGHT;
  },

  /**
   * Determine if we are running on a simulator.
   */
  isSimulator: function() {
    return this.model().match(/Simulator/) !== null;
  },

  /**
   * A convenience method for detecting that you're running on an iPad
   */
  isDeviceiPad: function () {
    //model is iPhone Simulator, even when running in iPad mode
    return this.model().match(/^iPad/) !== null ||
      this.name().match(/iPad Simulator/) !== null;
  },

  /**
   * A convenience method for detecting that you're running on an
   * iPhone or iPod touch
   */
  isDeviceiPhone: function () {
    return this.model().match(/^iPad/) === null &&
      this.name().match(/^iPad Simulator$/) === null;
  },

  /**
   * A shortcut for checking if target device is iPhone 5 (or iPod Touch
   * 5th generation)
   */
  isDeviceiPhone5: function () {
    var isIphone = this.isDeviceiPhone();
    var deviceScreen = this.rect();
    return isIphone && deviceScreen.size.height == 568;
  },

  /**
   * A convenience method for producing screenshots without status bar
   */
  captureAppScreenWithName: function (imageName) {
    var appRect = this.rect();

    appRect.origin.y += 20.0;
    appRect.size.height -= 20.0;

    return this.captureRectWithName(appRect, imageName);
  },

  logDeviceInfo: function () {
    UIALogger.logMessage("Dump Device:");
    UIALogger.logMessage("  model: " + this.model());
    UIALogger.logMessage("  rect: " + JSON.stringify(this.rect()));
    UIALogger.logMessage("  name: " + this.name());
    UIALogger.logMessage("  systemName: " + this.systemName());
    UIALogger.logMessage("  systemVersion: " + this.systemVersion());
  }
});
extend(UIAKeyboard.prototype, {
  KEYBOARD_TYPE_UNKNOWN: -1,
  KEYBOARD_TYPE_ALPHA: 0,
  KEYBOARD_TYPE_ALPHA_CAPS: 1,
  KEYBOARD_TYPE_NUMBER_AND_PUNCTUATION: 2,
  KEYBOARD_TYPE_NUMBER: 3,
  keyboardType: function () {
    if (this.keys().length < 12) {
      return this.KEYBOARD_TYPE_NUMBER;
    }
    else if (this.keys().firstWithName("a").isNotNil()) {
      return this.KEYBOARD_TYPE_ALPHA;
    }
    else if (this.keys().firstWithName("A").isNotNil()) {
      return this.KEYBOARD_TYPE_ALPHA_CAPS;
    }
    else if (this.keys().firstWithName("1").isNotNil()) {
      return this.KEYBOARD_TYPE_NUMBER_AND_PUNCTUATION;
    }
    else {
      return this.KEYBOARD_TYPE_UNKNOWN;
    }
  }
});

var typeString = function (pstrString, pbClear) {
  pstrString = pstrString.toString();
  // handle keyboard not being focused
  if (!this.hasKeyboardFocus()) {
    this.tap();
  }
  var kb, db; // keyboard, deleteButton
  var seconds = 2;
  var waitTime = 0.25;
  var maxAttempts = seconds / waitTime;
  var noSuccess = true;
  var failMsg = null;

  // attempt to get a successful keypress several times -- using the first character
  // this is a hack for iOS 6.x where the keyboard is sometimes "visible" before usable
  while ((pbClear || noSuccess) && 0 < maxAttempts--) {
    try {
      kb = target.frontMostApp().keyboard();
      // handle clearing
      if (pbClear) {
        db = kb.buttons()["Delete"];
        if (!db.isNotNil()) db = kb.keys()["Delete"]; // compatibilty hack

        // touchAndHold doesn't work without this next line... not sure why :(
        db.tap();
        pbClear = false; // prevent clear on next iteration
        db.touchAndHold(3.7);

      }

      if (pstrString.length !== 0) {
        kb.typeString(pstrString.charAt(0));
      }

      noSuccess = false; // here + no error caught means done
    }
    catch (e) {
      failMsg = e;
      UIATarget.localTarget().delay(waitTime);
    }
  }

  // report any errors that prevented success
  if (0 > maxAttempts && null !== failMsg) throw "typeString caught error: " + failMsg.toString();

  // now type the rest of the string
  try {
      if (pstrString.length > 0) kb.typeString(pstrString.substr(1));
  } catch (e) {
      if (-1 == e.toString().indexOf(" failed to tap ")) throw e;

      UIALogger.logDebug("Retrying keyboard action, typing slower this time");
      this.typeString("", true);
      kb.setInterKeyDelay(0.2);
      kb.typeString(pstrString);
  }

};

extend(UIATextField.prototype, {
  typeString: typeString,
  clear: function () {
    this.typeString("", true);
  }
});

extend(UIATextView.prototype, {
  typeString: typeString,
  clear: function () {
    this.typeString("", true);
  }
});

extend(UIAPickerWheel.prototype, {

  /*
   * Better implementation than UIAPickerWheel.selectValue
   * Works also for texts
   * Poorly works not for UIDatePickers -> because .values() which get all values of wheel does not work :(
   * I think this is a bug in UIAutomation!
   */
  scrollToValue: function (valueToSelect) {

    var element = this;

    var values = this.values();
    var pickerValue = element.value();

    // convert to string
    valueToSelect = valueToSelect + "";

    // some wheels return for .value()  "17. 128 of 267" ?? don't know why
    // throw away all after "." but be careful lastIndexOf is used because the value can
    // also have "." in it!! e.g.: "1.2. 13 of 27"
    if (pickerValue.lastIndexOf(".") != -1) {
      var currentValue = pickerValue.substr(0, pickerValue.lastIndexOf("."));
    }
    else {
      var currentValue = element.value();
    }

    var currentValueIndex = values.indexOf(currentValue);
    var valueToSelectIndex = values.indexOf(valueToSelect);

    if (valueToSelectIndex == -1) {
      fail("value: " + valueToSelect + " not found in Wheel!");
    }

    var elementsToScroll = valueToSelectIndex - currentValueIndex;

    UIALogger.logDebug("number of elements to scroll: " + elementsToScroll);
    if (elementsToScroll > 0) {

      for (i = 0; i < elementsToScroll; i++) {
        element.tapWithOptions({
          tapOffset: {
            x: 0.35,
            y: 0.67
          }
        });
        target.delay(0.7);
      }

    }
    else {

      for (i = 0; i > elementsToScroll; i--) {
        element.tapWithOptions({
          tapOffset: {
            x: 0.35,
            y: 0.31
          }
        });
        target.delay(0.7);
      }
    }
  },

  /*
   * Wheels filled with values return for .value()  "17. 128 of 267"
   *            ?? don't know why -> for comparisons this is unuseful!!
   * If you want to check a value of a wheel this function is very helpful
   */
  realValue: function () {

    // current value of wheel
    var pickerValue = this.value();

    // throw away all after "." but be careful lastIndexOf is used because the value can
    if (pickerValue.lastIndexOf(".") != -1) {
      return pickerValue.substr(0, pickerValue.lastIndexOf("."));
    }

    return this.value();
  }
});
