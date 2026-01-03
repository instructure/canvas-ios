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
import UIKit
@testable import Core

class UITableViewExtensionsTests: XCTestCase {
    class Cell: UITableViewCell {}
    func testDequeue() {
        let view = UITableView(frame: .zero)
        view.register(Cell.self, forCellReuseIdentifier: "Cell")
        XCTAssertNoThrow(view.dequeue(for: IndexPath(row: 0, section: 0)) as Cell)
    }

    func testRegister() {
        let table = UITableView(frame: .zero)
        table.registerCell(Cell.self)
        let cell = table.dequeueReusableCell(withIdentifier: "Cell") as? Cell
        XCTAssertNotNil(cell)
    }

    func testRegisterHeaderWithNib() {
        let table = UITableView(frame: .zero)
        table.registerHeaderFooterView(SectionHeaderView.self)
        let header: SectionHeaderView = table.dequeueHeaderFooter(SectionHeaderView.self)
        XCTAssertNotNil(header)
    }

    func testRegisterHeaderWithNoNib() {
        let table = UITableView(frame: .zero)
        table.registerHeaderFooterView(MockHeaderView.self, fromNib: false)
        let header = table.dequeueHeaderFooter(MockHeaderView.self)
        XCTAssertNotNil(header)
    }

    func testSetupDefaultSectionHeaderTopPadding() {
        UITableView.setupDefaultSectionHeaderTopPadding()
        XCTAssertEqual(UITableView.appearance().sectionHeaderTopPadding, 0)
    }

    class MockHeaderView: UITableViewHeaderFooterView {}
}
