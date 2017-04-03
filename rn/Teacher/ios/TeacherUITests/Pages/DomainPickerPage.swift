//
//  DomainPickerPage.swift
//  Teacher
//
//  Created by Ben Kraus on 3/14/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

import SoGrey
import EarlGrey

class DomainPickerPage {

  // MARK: Singleton

  static let sharedInstance = DomainPickerPage()
  private init() {}

  // MARK: Page Elements

  let domainField = e.selectBy(id: "domainPickerTextField")
  let connectButton = e.selectBy(label: "Search for domain.")

  // MARK: - Assertions
  
  func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)
    
    grey_dismissKeyboard()
    domainField.assertExists()
  }
  
  func assertDomainField(contains string: String, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    domainField.assertExists() // wait for element to exist. TODO: handle this in dsl.swift
    domainField.assert(with: grey_text(string))
  }
  
  // MARK: UI Actions
  
  func enterDomain(_ domain: String, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    domainField.assertExists() // wait for element to exist. TODO: handle this in dsl.swift
    domainField.perform(grey_replaceText(domain))
  }

  func openDomain(_ domain: String, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    enterDomain(domain)
    connectButton.tap()
  }

  func clearDomain(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    domainField.assertExists() // wait for element to exist. TODO: handle this in dsl.swift
    domainField.perform(grey_replaceText(""))
  }
}
