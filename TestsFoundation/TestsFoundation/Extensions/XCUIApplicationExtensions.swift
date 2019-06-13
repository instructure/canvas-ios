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
import XCTest

public extension XCUIApplication {
    func find(label: String, type: XCUIElement.ElementType = .any) -> Element {
       return XCUIElementWrapper(
            descendants(matching: type)
            .matching(NSPredicate(format: "%K == %@", #keyPath(XCUIElement.label), label))
            .firstMatch
        )
    }

    func find(labelContaining needle: String, type: XCUIElement.ElementType = .any) -> Element {
       return XCUIElementWrapper(
            descendants(matching: type)
            .matching(NSPredicate(format: "%K CONTAINS %@", #keyPath(XCUIElement.label), needle))
            .firstMatch
        )
    }

    func find(id: String, type: XCUIElement.ElementType = .any) -> Element {
        return XCUIElementWrapper(
            descendants(matching: type)
            .matching(NSPredicate(format: "%K == %@", #keyPath(XCUIElement.identifier), id))
            .firstMatch
        )
    }

    func find(type: XCUIElement.ElementType, index: Int = 0) -> Element {
        return XCUIElementWrapper(
            descendants(matching: type).element(boundBy: index)
        )
    }
}
