//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

// Print elementRef for object.description
extension ElementReference: CustomStringConvertible {
  public var description: String { return elementRef }
}

public struct ElementReference {

  let elementRef:String // {"ELEMENT":":wdc:1490810163185"}

  /*
   * Create new ElementReference from JSON status string
   *
   * {"status":0,"value":{"ELEMENT":":wdc:1490810163185"}}
   */
  init(_ status:String) {
    var parsedRef:String = ""

    if let refJSON = ElementReference.parseRefFromStatus(status) {
      if let refString = ElementReference.jsonToString(refJSON) {
        parsedRef = refString
      }
    }

    // TODO: handle null values
    // fatal error: Unable to parse data: {"status":0,"value":null}
    if parsedRef.isEmpty {
      fatalError("Unable to parse data: \(status)")
    }

    elementRef = parsedRef
  }

  /*
   * Parses JSON object from JSON status string
   *
   * {"status":0,"value":{"ELEMENT":":wdc:1490810163185"}} -> ["ELEMENT": ":wdc:1490810163185"]
   *
   */
  private static func parseRefFromStatus(_ jsonString:String) -> [String : String]? {
    var result:[String : String]? = nil

    if let data = jsonString.data(using: .utf8) {
      // string -> json object
      let json: [String : Any]?
      do {
        json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
      } catch {
        fatalError("Unable to parse data: \(data)")
      }

      if let value = json?["value"] as? [String: String]  {
        if value["ELEMENT"] != nil {
          result = value
        }
      }
    }

    return result
  }

  /*
   * Converts JSON object to JSON string
   *
   * ["ELEMENT": ":wdc:1490810163185"] -> {"ELEMENT":":wdc:1490810163185"}
   *
   */
  private static func jsonToString(_ obj:Any) -> String? {
    guard let json = try? JSONSerialization.data(withJSONObject: obj, options: []) else { return nil }
    return String(data: json, encoding: .utf8)
  }
}
