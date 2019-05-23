//
// Copyright (C) 2019-present Instructure, Inc.
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
import UIKit
import SwiftUITest

// todo: move this back to TestsFoundation once EarlGrey is a framework with modular headers
@objc
protocol TestHost {
    func reset()
    func logIn(domain: String, token: String)
    func show(_ route: String)
    func mockData(_ data: Data)
    func mockDownload(_ data: Data)
    func grey_getLabel(_ elementData: ElementData) -> GREYActionBlock
    func grey_getId(_ elementData: ElementData) -> GREYActionBlock
    func grey_getClassName(_ elementData: ElementData) -> GREYActionBlock
    func grey_getText(_ elementData: ElementData) -> GREYActionBlock
}

@objc
protocol ElementData {
    var label: String { get set }
    var id: String { get set }
    var className: String { get set }
    var text: String { get set }
}

@objc
class EGData: NSObject, ElementData {
    var label = ""
    var id = ""
    var className = ""
    var text = ""
}

extension ElementWrapper {
    var element: Element {
        return app.find(id: id)
    }
}

struct EGElementWrapper: Element {
    let element: GREYInteraction
    let testCase: XCTestCase

    init(_ element: GREYInteraction, _ testCase: XCTestCase) {
        self.element = element
        self.testCase = testCase
    }

    var exists: Bool {
        var err: NSError?
        self.element.assert(grey_notNil(), error: &err)
        return err == nil
    }

    var label: String {
        let elementData = EGData()
        let getLabel = host.grey_getLabel(elementData)
        element.perform(getLabel)
        return elementData.label
    }

    var id: String {
        let elementData = EGData()
        let getId = host.grey_getId(elementData)
        element.perform(getId)
        return elementData.id
    }

    var elementType: String {
        let elementData = EGData()
        let getClassName = host.grey_getClassName(elementData)
        element.perform(getClassName)
        return elementData.className
    }

    var isVisible: Bool {
        // adding waitToExist fails test! not sure why?
        return isVisibleNow
    }

    var isVisibleNow: Bool {
        var err: NSError?
        self.element.assert(grey_sufficientlyVisible(), error: &err)
        return err == nil
    }

    var value: String {
        let elementData = EGData()
        let getText = host.grey_getText(elementData)
        element.perform(getText)
        return elementData.text
    }

    var isEnabled: Bool {
        var err: NSError?
        self.element.assert(grey_enabled(), error: &err)
        return err == nil
    }

    var isEnabledNow: Bool {
        return isEnabled
    }

    func tap() {
        element.perform(grey_tap())
    }

    func typeText(_ text: String) {
        element.perform(grey_typeText(text))
    }

    func swipeDown() {
        element.perform(grey_swipeFastInDirection(GREYDirection.down))
    }

    func swipeUp() {
        element.perform(grey_swipeFastInDirection(GREYDirection.up))
    }

    // todo: update signature to accept parent information
    // earlgrey doesn't allow chaining on elements
    func child(label: String) -> Element {
        // grey_descendant
        fatalError("not implemented")
    }

    func child(elementType: XCUIElement.ElementType, index: Int) -> Element {
        fatalError("not implemented")
    }

    @discardableResult
    func waitToExist(_ timeout: Timeout) -> Bool {
        // TODO: update to grab timeout/polling value from SwiftUITest
        return GREYCondition(name: "waitToExist") { () -> Bool in
            var err: NSError?
            self.element.assert(grey_sufficientlyVisible(), error: &err)
            return err == nil
        }.wait(withTimeout: 10, pollInterval: 0.5)
    }

    func waitToVanish(_ timeout: Timeout) {
        _ = GREYCondition(name: "waitToExist") { () -> Bool in
            var err: NSError?
            self.element.assert(grey_notVisible(), error: &err)
            return err == nil
        }.wait(withTimeout: 10, pollInterval: 0.5)
    }
}

extension GREYInteraction {
  func toElement(_ testCase: XCTestCase) -> Element {
    return EGElementWrapper(self, testCase)
  }
}

// TODO: Move this into SwiftUITest once EarlGrey is a framework with modular headers
struct EarlGreyDriver: Driver {
    let app: XCUIApplication
    let testCase: XCTestCase

    init(_ app: XCUIApplication, testCase: XCTestCase) {
        self.app = app
        self.testCase = testCase
    }

    func find(label: String) -> Element {
        return EarlGrey.selectElement(
            with: grey_accessibilityLabel(label))
            .atIndex(0)
            .toElement(testCase)
    }

    func find(id: String) -> Element {
        return EarlGrey.selectElement(
            with: grey_accessibilityID(id))
            .atIndex(0)
            .toElement(testCase)
    }

    func find<T>(_ elementId: T) -> Element where T: ElementWrapper {
        return EarlGrey.selectElement(
            with: grey_accessibilityID(elementId.id))
            .atIndex(0)
            .toElement(testCase)
    }

    func find(type: String) -> Element {
        return EarlGrey.selectElement(
            with: grey_kindOfClassName(type))
            .atIndex(0)
            .toElement(testCase)
    }

    func find(label: String, type: String) -> Element {
        return EarlGrey.selectElement(with: grey_allOf([
                grey_accessibilityLabel(label),
                grey_kindOfClassName(type),
                ]))
                .atIndex(0)
                .toElement(testCase)
    }

    func find(id: String, type: String) -> Element {
        return EarlGrey.selectElement(
            with: grey_allOf([
                grey_accessibilityID(id),
                grey_kindOfClassName(type),
                ]))
            .atIndex(0)
            .toElement(testCase)
    }

    func find<T>(_ elementId: T, type: String) -> Element where T: ElementWrapper {
        return find(id: elementId.id, type: type)
    }

    func swipeDown() {
        xcuiApp?.swipeDown()
    }

    func swipeUp() {
        xcuiApp?.swipeUp()
    }

    func find(parentID: String, label: String) -> Element {
        return EarlGrey.selectElement(with: grey_allOf([
              grey_ancestor(grey_accessibilityID(parentID)),
              grey_accessibilityLabel(label),
            ]))
            .atIndex(0)
            .toElement(testCase)
    }

    func find(parentID: String, type: String, index: Int) -> Element {
        return EarlGrey.selectElement(with: grey_allOf([
              grey_ancestor(grey_accessibilityID(parentID)),
              grey_kindOfClassName(type),
            ]))
            .atIndex(UInt(index))
            .toElement(testCase)
    }
}
