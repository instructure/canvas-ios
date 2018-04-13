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

import Foundation

public struct JavascriptEvaluation {

  private static func isFunctionDefinition(_ script:String) -> Bool {
    let regex = try! NSRegularExpression(pattern: "^\\s*function\\s*\\w*\\s*\\(.*\\}\\s*$", options: [.anchorsMatchLines, .dotMatchesLineSeparators])

    let match = regex.matches(in: script, options: [], range: NSRange(location: 0, length: script.utf16.count))

    return !match.isEmpty
  }

  private static func escapeAndQuote(_ script:String, _ toWrap:String) -> String {
    var scriptBuffer = script

    scriptBuffer += "\""
    let isFunction = isFunctionDefinition(toWrap);
    if (isFunction) {
      scriptBuffer.append("return (");
    }

    for chr in toWrap {
      let c = String(chr)
      switch (chr) {
      case "\"":  // literally: "
        scriptBuffer += "\\" + c
      case "\'":  // literally: '
        scriptBuffer += "\\" + c
      case "\\":  // literally: \
        scriptBuffer += "\\" + c
      case "\n":  // literally a unix-newline.
        scriptBuffer += "\\n"
      case "\r":
        scriptBuffer += "\\r"
      case "\u{2028}":
        scriptBuffer += "\\u2028"
      case "\u{2029}":
        scriptBuffer += "\\u2029"
      default:
        scriptBuffer += c
      }
    }

    if isFunction {
      scriptBuffer += ").apply(null,arguments);"
    }

    scriptBuffer += "\""
    return scriptBuffer;
  }

  public static func wrapInFunction(_ script:String) -> String {
    return "(function(){" + script + "})()"
  }

  public static func atomize(script:String, args:String, windowReference:String?) -> String {
    var toExecute = "var my_wind = "

    if let window = windowReference {
      toExecute += "("
      toExecute += EvaluationAtom.GET_ELEMENT_ANDROID
      toExecute += ")("
      toExecute += window // todo: encode this?
      toExecute += "[\"WINDOW\"]);"
    } else {
      toExecute += "null;"
    }

    toExecute += "return (" + EvaluationAtom.EXECUTE_SCRIPT_ANDROID + ")("

    let conduitize = "true"

    toExecute = escapeAndQuote(toExecute, script)
    toExecute += ","
    toExecute += args // todo JSONify args. // [{"css":"input[name=\"pseudonym_session[unique_id]\"]"}]
    toExecute += ","
    toExecute += conduitize // JSON.stringify at webdriver level. Necessary for conduits.
    toExecute += ","
    toExecute += "my_wind)"

    return wrapInFunction(toExecute)
  }
}
