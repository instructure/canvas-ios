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
import XCTest

protocol Element {
    var greyInteraction: GREYInteraction { get }
}

// Automatic conformance of enum: String
extension Element where Self: RawRepresentable, Self.RawValue: StringProtocol {
    var id: String {
        return "\(String(describing: Self.self)).\(rawValue)"
    }

    var greyInteraction: GREYInteraction {
        return EarlGrey.selectElement(with: grey_accessibilityID(id)).atIndex(0)
    }
}

// Find a child of an identifiable element
class ChildElement: Element {
    let greyInteraction: GREYInteraction

    init(parentID: String, label: String) {
        greyInteraction = EarlGrey.selectElement(with: grey_allOf([
            grey_ancestor(grey_accessibilityID(parentID)),
            grey_accessibilityLabel(label),
        ])).atIndex(0)
    }

    init(parentID: String, segmentAt: UInt) {
        greyInteraction = EarlGrey.selectElement(with: grey_allOf([
            grey_ancestor(grey_accessibilityID(parentID)),
            grey_kindOfClassName("UISegment"),
        ])).atIndex(segmentAt)
    }
}

// Interacting with an Element
extension Element {
    func tap() {
        greyInteraction.perform(grey_tap())
    }

    func enterText(_ text: String) {
        greyInteraction.perform(grey_typeText(text))
    }

    var isEnabled: Bool {
        var error: NSError?
        greyInteraction.assert(grey_enabled(), error: &error)
        return error == nil
    }

    var isVisible: Bool {
        var error: NSError?
        greyInteraction.assert(grey_sufficientlyVisible(), error: &error)
        return error == nil
    }
}
