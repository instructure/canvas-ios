//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core
import SwiftUI

@available(iOS 13.0, *)
class NavBarStyleTests: CoreTestCase {
    func testReduce() {
        var style = NavBarStyle.global
        NavBarStyle.reduce(value: &style, nextValue: { .color(.green) })
        XCTAssertEqual(style, .color(.green))
    }

    func testViewExtension() throws {
        let controller = hostSwiftUIController(Text(verbatim: "SwiftUI!").navBarStyle(.color(.red)))
        XCTAssertEqual(controller.navBarStyle, .color(.red))
    }
}
