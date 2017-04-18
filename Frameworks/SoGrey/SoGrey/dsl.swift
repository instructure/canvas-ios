//
// Copyright (C) 2017-present Instructure, Inc.
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
import EarlGrey

// DSL that auto waits for elements to exist. Enables react-native compatability.

// MARK: Element timeout and poll

public let elementTimeout:TimeInterval = 60.0 // seconds
public let elementPoll:TimeInterval = 2.0 // seconds

// MARK: Element selectors

open class e {

  open static func selectBy(id:String, file:StaticString = #file, line:UInt = #line) -> GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID(id), file: file, line: line)
  }

  open static func selectBy(label:String, file:StaticString = #file, line:UInt = #line) -> GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityLabel(label), file: file, line: line)
  }

  @available(*, deprecated, message: "Only you can prevent memory leaks 🔥🐻")
  open static func firstElement(_ matcher:GREYElementInteraction) -> GREYElementInteraction {
    return matcher.atIndex(0)
  }
}

// MARK: Global utils

public func dump() {
  print(GREYElementHierarchy.hierarchyStringForAllUIWindows())
}

public func grey_fromFile(_ file:StaticString, _ line:UInt) {
  EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line)
}

public func waitFor(_ seconds:TimeInterval) {
  let timeout = Date(timeIntervalSinceNow: seconds)
  RunLoop.current.run(until: timeout)
}

public func grey_dismissKeyboard(_ file: StaticString = #file, _ line: UInt = #line) {
  grey_fromFile(file, line)

  UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

// MARK: Element actions

extension GREYInteraction {
  public func exists(file:StaticString = #file, line:UInt = #line) -> Bool {
    grey_fromFile(file, line)

    var errorOrNil: NSError?
    self.assert(with: grey_notNil(), error: &errorOrNil)
    let success = errorOrNil == nil

    return success
  }

  public func tap(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    self.assertExists(file: file, line: line)

    // condition does not raise error on failure.
    let success = GREYCondition(name: "Tapping element", block: { _ in
      var errorOrNil: NSError?
      self.perform(grey_tap(), error: &errorOrNil)
      let success = errorOrNil == nil

      return success
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)

    if (!success) { self.perform(grey_tap()) }
  }

  public func assertExists(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    let success = GREYCondition(name: "Waiting for element to exist", block: { _ in
      var errorOrNil: NSError?
      self.assert(with: grey_notNil(), error: &errorOrNil)
      let success = errorOrNil == nil
      return success
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)

    if (!success) { self.assert(with: grey_notNil()) }
  }

  public func assertHidden(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    let success = GREYCondition(name: "Waiting for element to disappear", block: { _ in
      var errorOrNil: NSError?
      self.assert(with: grey_nil(), error: &errorOrNil)
      let success = errorOrNil == nil
      return success
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)

    if (!success) { self.assert(with: grey_nil()) }
  }

}
