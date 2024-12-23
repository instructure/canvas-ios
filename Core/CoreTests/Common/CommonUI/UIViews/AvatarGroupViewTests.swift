//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import WebKit
@testable import Core

class AvatarGroupViewTests: CoreTestCase {
    func testLoadUsers() {
        let view = AvatarGroupView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        view.loadUsers([])
        view.layoutIfNeeded()
        XCTAssertEqual(view.backAvatarView.isHidden, true)
        XCTAssertEqual(view.frontAvatarView.frame, view.bounds)
        XCTAssertEqual(view.frontAvatarView.name, "")
        XCTAssertNil(view.frontAvatarView.url)

        view.loadUsers([(name: "Strong Bad", url: URL(string: "data:image/png,"))])
        view.layoutIfNeeded()
        XCTAssertEqual(view.backAvatarView.isHidden, true)
        XCTAssertEqual(view.frontAvatarView.frame, view.bounds)
        XCTAssertEqual(view.frontAvatarView.name, "Strong Bad")
        XCTAssertNotNil(view.frontAvatarView.url)

        view.loadUsers([
            (name: "Coach Z", url: nil),
            (name: "Strong Bad", url: URL(string: "data:image/png,"))
        ])
        view.layoutIfNeeded()
        let size = view.bounds.width / 3 * 2
        XCTAssertNotEqual(view.frontAvatarView.frame, view.bounds)
        XCTAssertEqual(view.frontAvatarView.name, "Coach Z")
        XCTAssertNil(view.frontAvatarView.url)
        XCTAssertEqual(view.backAvatarView.isHidden, false)
        XCTAssertEqual(view.backAvatarView.frame, CGRect(x: 0, y: 0, width: size, height: size))
        XCTAssertEqual(view.backAvatarView.name, "Strong Bad")
        XCTAssertNotNil(view.backAvatarView.url)
        XCTAssertNotNil(view.backAvatarView.layer.mask)
    }
}
