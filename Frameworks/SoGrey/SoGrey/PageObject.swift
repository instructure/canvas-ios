//
//  PageObject.swift
//  SoGrey
//
//  Created by Ben Kraus on 3/14/17.
//  Copyright © 2017 Instructure. All rights reserved.
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
      uniquePageElement().assert(with: grey_notNil(), error: &errorOrNil)
      let success = errorOrNil == nil
      return success
    }).wait(withTimeout: 30.0)
  }

  public static func waitForElementToLoad(element: GREYElementInteraction, file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    GREYCondition(name: "Waiting for \(element) to load", block: { _ in
        print("waiting for \(page) to load")
        
        var errorOrNil: NSError?
        element.assert(with: grey_notNil(), error: &errorOrNil)
        let success = errorOrNil == nil
        return success
    }).wait(withTimeout: 30.0)
  }
    
  public static func dismissKeyboard(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
