//
// Copyright 2018 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

protocol UITestElement {
    // The name of the element not including the page ID
    var rawValue: String { get }
    var a11yID: String { get }
}

// Mark - A11y Helpers
extension UITestElement {
    // The accessibility ID of the element
    // Example: AssignmentDetailsPage.name
    var a11yID: String {
        return "\(String(describing: type(of: self))).\(self.rawValue)"
    }
}

// MARK: - Assertions
extension UITestElement {
    static func assertEnabled(_ element: Self, _ enabled: Bool = true) {
        select(element).assert(enabled ? grey_enabled() : grey_not(grey_enabled()))
    }

    static func assertExists(_ element: Self, _ exists: Bool = true) {
        select(element).assert(exists ? grey_notNil() : grey_nil())
    }

    static func assertHidden(_ element: Self) {
        select(element).assert(grey_notVisible())
    }

    static func assertVisible(_ element: Self) {
        select(element).assert(grey_sufficientlyVisible())
    }

    static func assertText(_ element: Self, equals text: String) {
        select(element).assert(grey_anyOf([ grey_accessibilityLabel(text), grey_text(text) ]))
    }

    static func assertAlertExists() {
        EarlGrey.selectElement(with: grey_kindOfClass(NSClassFromString("_UIAlertControllerView")!)).assert(grey_sufficientlyVisible())
    }

    static func assertAlertHidden() {
        EarlGrey.selectElement(with: grey_kindOfClass(NSClassFromString("_UIAlertControllerView")!)).assert(grey_notVisible())
    }

    static func assertAlertActionExists(_ label: String) {
        selectAlertAction(label).assert(grey_sufficientlyVisible())
    }
}

// MARK: - Actions
extension UITestElement {
    static func findIdentifier(for label: String) -> String {
        return app!.descendants(matching: .any).matching(NSPredicate(
            format: "%K == %@", #keyPath(XCUIElement.label), label
        )).firstMatch.identifier
    }

    static func pick(_ element: Self, column: Int, value: String) {
        select(element).perform(grey_setPickerColumnToValue(column, value))
    }

    static func select(_ element: Self) -> GREYInteraction {
        return EarlGrey.selectElement(with: grey_accessibilityID(element.a11yID))
    }

    static func selectAlertAction(_ label: String) -> GREYInteraction {
        return EarlGrey.selectElement(with: grey_allOf([
            grey_accessibilityLabel(label),
            grey_kindOfClass(NSClassFromString("_UIAlertControllerActionView")!),
        ]))
    }

    static func selectCalloutAction(_ label: String) -> GREYInteraction {
        return EarlGrey.selectElement(with: grey_allOf([
            grey_accessibilityLabel(label),
            grey_not(grey_accessibilityTrait(.button)),
            grey_not(grey_accessibilityTrait(.staticText)),
        ]))
    }

    static func tap(_ element: Self) {
        select(element).perform(grey_tap())
    }

    static func tap(_ element: Self, at point: CGPoint) {
        select(element).perform(grey_tapAtPoint(point))
    }

    static func tap(label: String, traits: UIAccessibilityTraits = .button) {
        EarlGrey.selectElement(with: grey_allOf([
            grey_accessibilityLabel(label),
            grey_accessibilityTrait(traits),
            grey_sufficientlyVisible(),
        ])).perform(grey_tap())
    }

    static func tapAlertAction(_ label: String) {
        selectAlertAction(label).perform(grey_tap())
    }

    static func tapCalloutAction(_ label: String) {
        selectCalloutAction(label).perform(grey_tap())
    }

    static func typeText(_ text: String, in element: Self) {
        select(element).perform(grey_typeText(text))
    }

    static func waitToExist(_ element: Self, timeout: TimeInterval) {
        let exists = app?.descendants(matching: .any).matching(identifier: element.a11yID).firstMatch.waitForExistence(timeout: timeout) ?? false
        XCTAssertTrue(exists, "Timeout expired waiting for \(element.a11yID) to exist.")
    }
}

extension UITestElement where Self: CaseIterable {
    static func assertPageObjectsExist() {
        allCases.forEach { assertExists($0) }
    }
}
