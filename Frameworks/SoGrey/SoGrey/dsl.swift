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
import EarlGrey

// MARK: Element timeout and poll

public var elementTimeout:TimeInterval = 4.0 // seconds
public let elementPoll:TimeInterval = 1.0 // seconds

// MARK: Element selectors

open class e {

  open static func selectBy(id:String, file:StaticString = #file, line:UInt = #line) -> GREYInteraction {
    return EarlGrey.selectElement(with: grey_accessibilityID(id), file: file, line: line)
  }

  open static func selectBy(label:String, file:StaticString = #file, line:UInt = #line) -> GREYInteraction {
    return EarlGrey.selectElement(with: grey_accessibilityLabel(label), file: file, line: line)
  }

  open static func selectBy(matchers:[GREYMatcher], file:StaticString = #file, line:UInt = #line) -> GREYInteraction {
    return EarlGrey.selectElement(with: grey_allOf(matchers), file: file, line: line)
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

struct Stopwatch {
  var startTime:CFTimeInterval;

  init() {
    startTime = CACurrentMediaTime()
  }

  mutating func start() {
    startTime = CACurrentMediaTime()
  }

  // stopwatch.stop(#function)
  func stop(_ methodName:String)  {
    let elapsedTime = CACurrentMediaTime() - startTime
    print("\(methodName) Polled for \(elapsedTime) seconds. Timeout: \(elementTimeout), Poll: \(elementPoll)")
  }
}

extension GREYInteraction {
  public func exists(file:StaticString = #file, line:UInt = #line) -> Bool {
    grey_fromFile(file, line)

    var errorOrNil: NSError?
    self.assert(grey_notNil(), error: &errorOrNil)
    let success = errorOrNil == nil

    return success
  }

  public func tap(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    self.assertExists(file: file, line: line)

    let stopwatch = Stopwatch()
    // condition does not raise error on failure.
    let success = GREYCondition(name: "Tapping element", block: { _ in
      var errorOrNil: NSError?
      self.perform(grey_tap(), error: &errorOrNil)
      let success = errorOrNil == nil

      return success
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)
    stopwatch.stop(#function)

    if (!success) { self.perform(grey_tap()) }
  }

  public func tapUntilHidden(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    self.assertExists(file: file, line: line)

    let stopwatch = Stopwatch()
    let success = GREYCondition(name: "Waiting for element to activate", block: { _ in
      var ignoredError: NSError?
      self.perform(grey_tap(), error: &ignoredError)
      return !self.exists()
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)
    stopwatch.stop(#function)

    if !success { self.assert(grey_nil()) }
  }

  public func assertExists(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    let stopwatch = Stopwatch()
    let success = GREYCondition(name: "Waiting for element to exist", block: { _ in
      var errorOrNil: NSError?
      self.assert(grey_notNil(), error: &errorOrNil)
      let success = errorOrNil == nil
      return success
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)
    stopwatch.stop(#function)

    if (!success) { self.assert(grey_notNil()) }
  }

  public func assertHidden(file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)

    let stopwatch = Stopwatch()
    let success = GREYCondition(name: "Waiting for element to disappear", block: { _ in
      var errorOrNil: NSError?
      self.assert(grey_nil(), error: &errorOrNil)
      let success = errorOrNil == nil
      return success
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)
    stopwatch.stop(#function)

    if (!success) { self.assert(grey_nil()) }
  }

  public func assertContains(text:String, file:StaticString = #file, line:UInt = #line) {
    grey_fromFile(file, line)
    let assertionBlock = GREYAssertionBlock(name: "Contains Text", assertionBlockWithError: { element, errorOrNil -> Bool in
      let elementObject = element as? NSObject
      if let labelText = elementObject?.accessibilityLabel {
        return labelText.range(of:text) != nil
      }
        return false
    })
    self.assert(assertionBlock)
  }
}
