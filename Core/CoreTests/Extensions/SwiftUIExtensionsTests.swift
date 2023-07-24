//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import SwiftUI
@testable import Core
import TestsFoundation

class SwiftUIExtensionsTests: CoreTestCase {

    func testFormattedNumberTextInitializer() {
        XCTAssertEqual(Text(0.12, number: .percent), Text(verbatim: "12%"))
    }

    func testAttributedtext() {
        let testColor = Color.red
        let testText = "test text"
        let attribute = AttributeContainer([.foregroundColor: testColor])
        let testee = Text(testText) {
            $0.setAttributes(attribute)
        }
        let attributedString = AttributedString(testText, attributes: attribute)
        XCTAssertEqual(testee, Text(attributedString))
    }

    func testIf() {
        var controller = hostSwiftUIController(testIfView(state: true))
        var tree = controller.testTree
        XCTAssertEqual(tree?.find(id: "test")?.info as? String, "true")
        controller = hostSwiftUIController(testIfView(state: false))
        tree = controller.testTree
        XCTAssertEqual(tree?.find(id: "test")?.info as? String, "false")
    }

    private struct testIfView: View {
        @State var state: Bool
        var body: some View {
            Text("test").testID("test", info: "false").if(state) { text in
                text.testID("test", info: "true")
            }
        }
    }
}
