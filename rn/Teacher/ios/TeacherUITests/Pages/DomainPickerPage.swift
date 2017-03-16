//
//  DomainPickerPage.swift
//  Teacher
//
//  Created by Ben Kraus on 3/14/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import SoGrey
import EarlGrey

class DomainPickerPage: PageObject {
  
  // MARK: - Page objects
  
  private static var domainField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("domainPickerTextField"))
  }
  
  static func uniquePageElement() -> GREYElementInteraction {
    return domainField
  }
  
  // MARK: - Assertion helpers
  
  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    dismissKeyboard()
    domainField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
  }
  
  static func assertDomainField(contains string: String, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    domainField.assert(with: grey_text(string))
  }
  
  // MARK: UI actions
  
  static func enterDomain(_ domain: String, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    domainField.perform(grey_replaceText(domain))
  }
  
  static func clearDomain(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    domainField.perform(grey_replaceText(""))
  }
}
