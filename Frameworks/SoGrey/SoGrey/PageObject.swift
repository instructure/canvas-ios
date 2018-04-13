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

import EarlGrey

public protocol PageObject {
  static func assertPageObjects(_ file: StaticString, _ line: UInt)

  // designate 1 element on each page that can be used in a wait function to ensure the page is loaded
  static func uniquePageElement() -> GREYElementInteraction
}

extension PageObject {
  public static var page: String {
    return String(describing: self)
  }

  public static func waitForPageToLoad(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    GREYCondition(name: "Waiting for \(page) to load", block: { _ in
      print("waiting for \(page) to load")

      var errorOrNil: NSError?
      uniquePageElement().assert(grey_notNil(), error: &errorOrNil)
      let success = errorOrNil == nil
      return success
    }).wait(withTimeout: 30.0)
  }

  public static func waitForElementToLoad(element: GREYElementInteraction, file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    GREYCondition(name: "Waiting for \(element) to load", block: { _ in
        print("waiting for \(page) to load")
        
        var errorOrNil: NSError?
        element.assert(grey_notNil(), error: &errorOrNil)
        let success = errorOrNil == nil
        return success
    }).wait(withTimeout: 30.0)
  }
    
  public static func dismissKeyboard(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
