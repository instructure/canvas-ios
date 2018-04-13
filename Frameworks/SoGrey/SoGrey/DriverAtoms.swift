/*
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Note: This file contains code based on Espresso Web v2.2.2

import EarlGrey

/**
 * A collection of Javascript Atoms from the WebDriver project.
 */
public struct DriverAtoms {

  private static let debug:Bool = false

  public static func findElement(locator:Locator, value: String) -> ElementReference? {
    let locatorJSON = self.makeLocatorJSON(locator: locator, value: value)

    var jsExecutionResult: NSString? = ""

    // element reference - last argument.
    // ( function() {...} )({css: "#someid"}, optEleRef)

    let jsAtom = JavascriptEvaluation.atomize(script: WebDriverAtomScripts.FIND_ELEMENT_ANDROID, args: locatorJSON, windowReference: nil)

    EarlGrey.selectElement(with: grey_kindOfClass(UIWebView.self))
      .perform(grey_javaScriptExecution(jsAtom, &jsExecutionResult))

    guard let jsResult = jsExecutionResult else { return nil }
    let result = String(describing: jsResult)

    if debug { print("Execution result: \(result)") }

    return ElementReference(result)
  }

  public static func webKeys(element:ElementReference, value: String) {
    var jsExecutionResult: NSString? = ""

    // args
    // [{"ELEMENT":":wdc:1490890919529"},"1490214466@c108a1f8-fb2b-4712-8790-d71d1ab06878.com"]

    let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
    let args = "[\(element), \"\(escapedValue)\"]"

    let jsAtom = JavascriptEvaluation.atomize(script: WebDriverAtomScripts.SEND_KEYS_ANDROID,
                                              args: args,
                                              windowReference: nil)

    EarlGrey.selectElement(with: grey_kindOfClass(UIWebView.self))
      .perform(grey_javaScriptExecution(jsAtom, &jsExecutionResult))

    guard let jsResult = jsExecutionResult else { return }
    let result = String(describing: jsResult)

    if debug { print("Execution result: \(result)") }
  }

  private static func makeLocatorJSON(locator:Locator, value:String) -> String {
    // { css: "#someid" }

    let locatorString = locator.rawValue
    let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")

    return "[{\(locatorString): \"\(escapedValue)\"}]";
  }
}
