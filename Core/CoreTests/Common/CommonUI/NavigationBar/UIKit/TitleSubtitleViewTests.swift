//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Core

class TitleSubtitleViewTests: XCTestCase {
    func testCreate() {
        let view = TitleSubtitleView.create()
        XCTAssertEqual(view.titleLabel.text, "")
        XCTAssertEqual(view.subtitleLabel.text, "")
    }

    func testRecreate() {
        let view = TitleSubtitleView.create()
        view.title = "t"
        view.subtitle = "s"
        let copy = view.recreate()
        XCTAssertEqual(copy.title, "t")
        XCTAssertEqual(copy.subtitle, "s")
    }

    func testTitle() {
        let view = TitleSubtitleView.create()
        XCTAssertEqual(view.title, view.titleLabel?.text)
        view.title = "title"
        XCTAssertEqual(view.title, "title")
        XCTAssertEqual(view.titleLabel?.text, "title")
    }

    func testSubtitle() {
        let view = TitleSubtitleView.create()
        XCTAssertEqual(view.subtitle, view.subtitleLabel?.text)
        view.subtitle = "subtitle"
        XCTAssertEqual(view.subtitle, "subtitle")
        XCTAssertEqual(view.subtitleLabel?.text, "subtitle")
    }

    func testTintColorDidChange() {
        let view = TitleSubtitleView.create()
        view.tintColor = .red
        view.tintColorDidChange()
        XCTAssertEqual(view.titleLabel.textColor, .red)
        XCTAssertEqual(view.subtitleLabel.textColor, .red)
    }
}
