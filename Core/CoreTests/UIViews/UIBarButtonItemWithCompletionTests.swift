//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

@testable import Core
import XCTest

class UIBarButtonItemWithCompletionTests: XCTestCase {
    func testProperties() {
        let title = "title"
        let style = UIBarButtonItem.Style.done
        let view = UIBarButtonItemWithCompletion(
            title: title,
            style: style,
            actionHandler: {}
        )
        XCTAssertEqual(view.title, title)
        XCTAssertEqual(view.style, style)
    }

    func testCompletion() {
        let expectation = expectation(description: "Completion gets called")
        let completion: () -> Void = {
            expectation.fulfill()
        }

        let view = UIBarButtonItemWithCompletion(title: nil, actionHandler: completion)
        view.buttonDidTap(sender: view)
        waitForExpectations(timeout: 0.1)
    }
}
