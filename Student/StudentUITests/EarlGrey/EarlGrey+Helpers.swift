//
// Copyright (C) 2018-present Instructure, Inc.
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

extension GREYInteraction {
    func assertText(equals value: String) {
        assert(grey_accessibilityLabel(value))
    }
}

extension XCUIApplication {
    public func dismissKeyboard(
        file: StaticString = #file,
        line: UInt = #line) throws {
        return try EarlGreyImpl.invoked(fromFile: file.description, lineNumber: line)
            .dismissKeyboard(in: self)
    }
}
